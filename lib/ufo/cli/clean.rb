class Ufo::CLI
  class Clean < Base
    def run
      folders = %w[log output tmp]
      folders = folders.map do |folder|
        ".ufo/#{folder}"
      end
      sure?("Will remove folders: #{folders.join(' ')}")
      folders.each do |folder|
        FileUtils.rm_rf("#{Ufo.root}/#{folder}")
      end
      logger.info "Removed folders: #{folders.join(' ')}"
    end
  end
end
