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
      ::Balancer::SecurityGroup.new(@options.dup.merge(mute: false, name: @service))
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
      # remove known dependencies in security group first
      puts "Removing known dependencies in security group first."
      destroy_fargate_security_group
      balancer_security_group.destroy
    end

    def destroy_fargate_security_group
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
      ec2.revoke_security_group_ingress(params) if permission

      ec2.delete_security_group(group_id: sg.group_id)
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
  end
end
