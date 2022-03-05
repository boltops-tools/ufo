class Ufo::Cfn::Stack::Builder::Resources
  class Listener < Base
    def build
      {
        Type: "AWS::ElasticLoadBalancingV2::Listener",
        Condition: "CreateElbIsTrue",
        Properties: properties,
      }
    end

    def properties
      {
        DefaultActions: default_actions,
        LoadBalancerArn: {Ref: "Elb"},
        Port: port,
        Protocol: protocol,
      }
    end

    def protocol
      vars[:default_listener_protocol]
    end

    def port
      80
    end

    def default_actions
      elb = Ufo.config.elb
      default_actions = elb.default_actions # allow use to override for full control like redirection support
      return default_actions if default_actions

      redirect = elb.redirect
      if redirect.enabled
        [redirect_action(redirect)]
      else
        [default_action]
      end
    end

    def redirect_action(redirect)
      {
        Type: "redirect",
        RedirectConfig: {
          Protocol: redirect.protocol,
          StatusCode: "HTTP_#{redirect.code}", # HTTP_301 and HTTP_302 are valid
          Port: redirect.port,
        }
      }
    end

    def default_action
      {
        Type: "forward",
        TargetGroupArn: {
          "Fn::If": [
            "ElbTargetGroupIsBlank",
            {Ref: "TargetGroup"},
            {Ref: "ElbTargetGroup"}
          ]
        }
      }
    end
  end
end
