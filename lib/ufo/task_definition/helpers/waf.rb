module Ufo::TaskDefinition::Helpers
  module Waf
    include Ufo::Utils::CallLine
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
        logger.warn "WARN: Web ACL not found: #{name}".color(:yellow)
        call_line = ufo_call_line
        DslEvaluator.print_code(call_line)
      end
    end
  end
end
