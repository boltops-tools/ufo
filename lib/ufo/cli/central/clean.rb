class Ufo::CLI::Central
  class Clean < Base
    def run
      path = "#{ENV['HOME']}/.ufo/central"
      sure?("Will remove folder with repo caches: #{pretty_home(path)}")
      FileUtils.rm_rf(path)
      log "Removed: #{pretty_home(path)}"
    end
  end
end
