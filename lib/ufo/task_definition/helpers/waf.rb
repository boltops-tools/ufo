module Ufo::TaskDefinition::Helpers
  module Waf
    include Ufo::Utils::Pretty

    # Waf names are uniq within their scope. Tested with AWS console
    # Only use regional since this is for ELB support
    # Returns waf arn
    def waf(name, options={})
      resp = waf_client.list_web_acls(
        scope: "REGIONAL", # required, accepts CLOUDFRONT, REGIONAL
        # next_marker: "NextMarker",
        # limit: 1,
      )
      web_acl = resp.web_acls.find do |acl|
        acl.name == name
      end
      if web_acl
        web_acl.arn
      else
        # Logger causes infinite loop when waf helper used in .ufo/
        call_line = pretty_path(caller[0])
        logger.info <<~EOL.color(:yellow)
          WARN: Web ACL not found: #{name}
          Called from:

              #{call_line}

          Are you sure it's a regional WAF ACL?
        EOL
      end
    end
  end
end
