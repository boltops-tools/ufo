class Ufo::Cfn::Stack::Builder
  class Conditions < Base
    def build
      text =<<~EOL
        CreateElbIsTrue:
          Fn::Equals:
          - Ref: CreateElb
          - true
        ElbTargetGroupIsBlank:
          Fn::Equals:
          - Ref: ElbTargetGroup
          - ''
        CreateTargetGroupIsTrue:
          Fn::And:
          - Condition: CreateElbIsTrue
          - Condition: ElbTargetGroupIsBlank
        EcsDesiredCountIsBlank:
          Fn::Equals:
          - Ref: EcsDesiredCount
          - ''
      EOL
      Ufo::Yaml.load(text)
    end
  end
end
