module Ufo::TaskDefinition::Helpers
  module Acm
    # returns cert arn
    def acm_cert(domain)
      certs = acm_certs
      cert = certs.find do |c|
        c.domain_name == domain
      end
      cert.certificate_arn if cert
    end

    # TODO: handle when there are lots of certs by paging
    def acm_certs
      resp = acm.list_certificates
      resp.certificate_summary_list
    end
  end
end
