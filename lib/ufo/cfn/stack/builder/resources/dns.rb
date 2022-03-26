class Ufo::Cfn::Stack::Builder::Resources
  class Dns < Base
    def build
      return unless vars[:create_route53]

      props = {
        Name: dns_name, # {stack_name}.yourdomain. dont forget the trailing period
        Comment: dns.comment,
        Type: dns.type, # CNAME
        TTL: dns.ttl, # 60 ttl has special casing
        ResourceRecords: [resource_record]
      }
      # HostedZoneName: yourdomain. # dont forget the trailing period
      props[:HostedZoneName] = hosted_zone_name if hosted_zone_name
      props[:HostedZoneId] = dns.hosted_zone_id if dns.hosted_zone_id

      {
        Type: "AWS::Route53::RecordSet",
        Properties: props
      }
    end

  private
    def resource_record
      existing = Ufo.config.elb.existing
      if existing.target_group
        existing_dns_name
      else
        {"Fn::GetAtt": "Elb.DNSName"}
      end
    end

    def existing_dns_name
      existing = Ufo.config.elb.existing
      resp = elb.describe_target_groups(target_group_arns: [existing.target_group])
      target_group = resp.target_groups.first
      load_balancer_arns = target_group.load_balancer_arns
      if load_balancer_arns.size == 1
        resp = elb.describe_load_balancers(load_balancer_arns: load_balancer_arns)
        load_balancer = resp.load_balancers.first
        load_balancer.dns_name
      else
        return existing.dns_name if existing.dns_name
        logger.error "ERROR: config.existing.dns_name must to be set".color(:red)
        logger.error <<~EOL
          This target group is associated with multiple load balancers.
          UFO cannot infer the dns name in this case. You must set:

              config.existing.dns_name

          Info:

              target group: #{existing.target_group}
              load balancers: #{load_balancer_arns}

        EOL
        exit 1
      end
    end

    def dns_name
      return unless dns.domain || dns.name
      name = dns.name # my.domain.com
      name ||= "#{@stack_name}.#{dns.domain}" # demo-web-dev.domain.com
      ensure_trailing_dot(name)
    end

    def hosted_zone_name
      return if dns.hosted_zone_id # hosted_zone_id takes precedence over hosted_zone_name
      return unless dns.domain || dns.host_zone_name
      name = dns.hosted_zone_name
      name ||= dns.domain
      ensure_trailing_dot(name)
    end

    def ensure_trailing_dot(s)
      s.ends_with?('.') ? s : "#{s}."
    end

    def dns
      Ufo.config.dns
    end
  end
end
