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
      dns_name = Ufo.config.elb.existing.dns_name
      dns_name ? dns_name : {"Fn::GetAtt": "Elb.DNSName"}
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
