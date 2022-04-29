class Ufo::Cfn::Stack::Builder::Resources
  class ListenerCertificate < ListenerSsl
    def build
      return unless certificates && certificates.size >= 1 # already removed firt cert
      {
        Type: "AWS::ElasticLoadBalancingV2::ListenerCertificate",
        Condition: "CreateElbIsTrue",
        Properties: properties,
      }
    end

    def properties
      {
        Certificates: certificates,
        ListenerArn: {Ref: "ListenerSsl"}
      }
    end

    def certificates
      ssl = Ufo.config.elb.ssl
      if ssl.certificates
        certs = normalize(ssl.certificates)
        # CloudFormation has weird interface
        # Only one cert allowed at the AWS::ElasticLoadBalancingV2::Listener
        # https://stackoverflow.com/questions/54447250/how-to-set-multiple-certificates-for-awselasticloadbalancingv2listener
        # Also note the docs say "You can specify one certificate per resource."
        # But tested and multiple certs here work
        certs[1..-1] # dont include the first one
      end
    end
  end
end
