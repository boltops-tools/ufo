class Ufo::Setting
  class SecurityGroups
    include Ufo::Settings
    extend Memoist

    def initialize(service, type)
      @service, @type = service, type
    end

    def load
      groups = network[@type] # IE: network[:ecs_security_groups] or network[:elb_security_groups]
      return [] unless groups

      case groups
      when Array # same security groups used for all services
        groups
      when Hash # service specific security groups
        groups[@service.to_sym] || []
      end
    end
  end
end
