class Ufo::Stack::Builder
  class Conditions < Base
    def build
      {
        CreateElbIsTrue: {
          "Fn::Equals": [{Ref: "CreateElb"}, true]
        },
        ElbTargetGroupIsBlank: {
          "Fn::Equals": [{Ref: "ElbTargetGroup"}, ""]
        },
        CreateTargetGroupIsTrue: {
          "Fn::And": [
            {Condition: "CreateElbIsTrue"},
            {Condition: "ElbTargetGroupIsBlank"},
          ]
        },
        EcsDesiredCountIsBlank: {
          "Fn::Equals": [{Ref: "EcsDesiredCount"}, ""]
        }
      }
    end
  end
end
