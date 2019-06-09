class Ufo::Apps
  class Cluster
    def self.all
      new.all
    end

    def all
      Ufo.check_ufo_project!
      clusters = if settings[:service_cluster]
        settings[:service_cluster].values
      elsif settings[:cluster]
        settings[:cluster]
      else
        Ufo.env
      end
      [clusters].flatten.compact
    end

  private
    def settings
      @settings ||= Ufo.settings
    end
  end
end
