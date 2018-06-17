module Ufo
  class SecurityGroup
    autoload :Helper, "ufo/security_group/helper"

    extend Memoist
    include AwsService

    attr_reader :group_id
    def initialize(options)
      @options = options
      @service = options[:service]
    end

    # delegate to Balancer SecurityGroup when possible to leverage common code
    def balancer_security_group
      ::Balancer::SecurityGroup.new(@options.merge(name: @service))
    end
    memoize :balancer_security_group

    def create
      @group_id = balancer_security_group.create_security_group(@service)
      elb_group_id = balancer_security_group.find_security_group("#{@service}-elb").group_id

      # TODO: Get ports from the container definition or docker helper. Also allow
      # user to be able to sent this from the params.yml file.
      from_port = "0"
      to_port = "65535"
      balancer_security_group.authorize_port(
        description: "ufo elb access",
        from_port: from_port,
        group_id: group_id,
        groups: elb_group_id,
        to_port: to_port,
      )

      ec2.create_tags(resources: [group_id], tags: [{
        key: "Name",
        value: @service,
      },
        key: "ufo",
        value: @service
      ])

      @group_id
    end

    def destroy
      sg = balancer_security_group.find_security_group(@service)
      return unless sg

      retries = 0
      begin
        ec2.delete_security_group(group_id: sg.group_id)
        say "Deleted security group: #{sg.group_id}"
      rescue Aws::EC2::Errors::DependencyViolation => e
        # retry because it takes some time for the load balancer to be deleted
        # and that can cause a DependencyViolation exception
        retries += 1
        if retries <= 5
          if retries == 1
            say "WARN: #{e.class} #{e.message}"
            say "Unable to delete the security group because it's still in use by another resource. This might be the ELB which can take a little time to delete. Backing off expondentially and will try to delete again."
          end
          seconds = 2**retries
          say "Retry: #{retries+1} Delay: #{seconds}s"
          sleep seconds
          retry
        else
          say "WARN: #{e.class} #{e.message}"
          say "Unable to delete the security group because it's still in use by another resource. Leaving the security group behind: #{sg.group_id}"
        end
      end
    end

    def revoke
      sg = balancer_security_group.find_security_group(@service)
      return unless sg

      perm = sg.ip_permissions.find do |perm|
        perm.user_id_group_pairs.find do |pair|
          pair.description  == "ufo elb access"
        end
      end
      unless perm
        puts "WARN: Unable to delete auto-created ecs security group.  The original ufo added permission was not found. Leaving the security group #{sg.group_id} behind."
        return
      end

      pair = perm.user_id_group_pairs.find do |pair|
        pair.description  == "ufo elb access"
      end
      unless pair
        puts "WARN: Unable to find the ufo added rule in the security group. Leaving security group behind."
        return
      end

      # Need to build up the structure exactly vs reusing the params from the found
      # security group. Because the response has empty parameters that messes up the
      # the api call.
      permission = {
        from_port: perm[:from_port],
        to_port: perm[:to_port],
        ip_protocol: perm[:ip_protocol],
        user_id_group_pairs: [{
          description: pair[:description],
          group_id: pair[:group_id],
          user_id: pair[:user_id],
        }]
      }
      params = {
        group_id: sg.group_id,
        ip_permissions: [permission]
      }

      # Must revoke the elb security group dependency first
      ec2.revoke_security_group_ingress(params) if permission
    end

    # Add the security option to params for the create_service call
    def add_security_group_option(options)
      return unless options[:network_configuration] &&
                    options[:network_configuration][:awsvpc_configuration] &&
                    options[:network_configuration][:awsvpc_configuration][:security_groups]

      groups = options[:network_configuration][:awsvpc_configuration][:security_groups]
      found = groups.find_index { |g| g == "auto" }
      if found
        groups[found] = @group_id
        # override original options
        options[:network_configuration][:awsvpc_configuration][:security_groups] = groups
      end

      options
    end

    def say(text=nil)
      puts text unless ::Balancer.log_level == :warn
    end
  end
end
