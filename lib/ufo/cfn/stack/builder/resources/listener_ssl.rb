class Ufo::Cfn::Stack::Builder::Resources
  class ListenerSsl < Listener
    def build
      return unless vars[:create_listener_ssl]
      super
    end

    def properties
      props = super
      # CloudFormation has weird interface
      # Only one cert allowed at the AWS::ElasticLoadBalancingV2::Listener
      # https://stackoverflow.com/questions/54447250/how-to-set-multiple-certificates-for-awselasticloadbalancingv2listener
      props[:Certificates] = [certificates.first] # first one only
      props
    end

    def protocol
      vars[:default_listener_ssl_protocol]
    end

    def port
      Ufo.config.elb.ssl.port
    end

    # Do not use redirect settings. Only use by normal http listener
    def default_actions
      [default_action]
    end

    # nil on purpose
    def certificates
      ssl = Ufo.config.elb.ssl
      normalize(ssl.certificates) if ssl.certificates
    end

    def normalize(*certs)
      certs = certs.flatten.compact
      certs.map do |cert|
        if cert.is_a?(String)
          {CertificateArn: cert}
        else # Assume correct Hash structure
          cert
        end
      end
    end
  end
end
