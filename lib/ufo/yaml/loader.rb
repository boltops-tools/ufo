require "yaml"

class Ufo::Yaml
  class Loader
    def initialize(text)
      @text = text
    end

    def load
      add_domain_types!
      YAML.load(@text)
    end

  private
    def add_domain_types!
      intrinsic_functions.each do |name|
        YAML.add_domain_type('', name) do |type,val|
          key = type.split('::').last
          key = "Fn::" + key unless name == 'Ref'
          { key => val }
        end
      end
    end

    def intrinsic_functions
      %w[
        And
        Base64
        Cidr
        Equals
        FindInMap
        GetAtt
        GetAZs
        If
        If
        ImportValue
        Join
        Not
        Or
        Ref
        Select
        Split
        Sub
        Transform
      ]
    end
  end
end
