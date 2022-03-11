# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-wafv2-webaclassociation.html
class Ufo::Cfn::Stack::Builder::Resources
  class WafAssociation < Base
    def build
      web_acl_arn = Ufo.config.waf.web_acl_arn
      return if web_acl_arn.blank?

      {
        Type: "AWS::WAFv2::WebACLAssociation",
        Properties: {
          ResourceArn: {Ref: "Elb"},  # String,
          WebACLArn:   web_acl_arn,   # String
        }
      }
    end
  end
end
