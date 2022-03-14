module Ufo::TaskDefinition::Helpers
  module Acm
    include Ufo::Utils::CallLine
    include Ufo::Utils::Pretty

    # returns cert arn
    def acm_cert(domain)
      certs = acm_certs
      cert = certs.find do |c|
        c.domain_name == domain
      end
      if cert
        cert.certificate_arn
      else
        # Logger causes infinite loop when waf helper used in .ufo/
        logger.warn "WARN: ACM cert not found: #{domain}".color(:yellow)
        call_line = ufo_config_call_line
        DslEvaluator.print_code(call_line)
        nil
      end
    end

    # TODO: handle when there are lots of certs by paging
    def acm_certs
      resp = acm.list_certificates
      resp.certificate_summary_list
    end
  end
end
