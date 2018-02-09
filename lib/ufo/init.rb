require 'colorize'
require 'erb'

module Ufo
  class Init
    def initialize(options = {})
      @options = options
      @project_root = options[:project_root] || '.'
    end

    def setup
      puts "Setting up ufo project...".blue unless @options[:quiet]
      source_root = File.expand_path("../../starter_project", __FILE__)
      # https://ruby-doc.org/core-2.2.0/Dir.html
      # use the File::FNM_DOTMATCH flag or something like "{*,.*}".
      paths = Dir.glob("#{source_root}/**/{*,.*}").
                select {|p| File.file?(p) }
      paths.each do |src|
        dest = src.gsub(%r{.*starter_project/},'')
        dest = "#{@project_root}/#{dest}"

        if File.exist?(dest) and !@options[:sure]
          puts "exists: #{dest}".yellow unless @options[:quiet]
        else
          dirname = File.dirname(dest)
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
          if dest =~ /\.erb$/
            FileUtils.cp(src, dest)
          else
            write_erb_result(src, dest)
          end
          puts "created: #{dest}".green unless @options[:quiet]
        end
      end
      puts "Starter ufo files created.".blue
      File.chmod(0755, "#{@project_root}/bin/deploy")
      add_gitignore
    end

    def write_erb_result(src, dest)
      source = IO.read(src)
      b = ERBContext.new(@options).get_binding
      output = ERB.new(source).result(b)
      IO.write(dest, output)
    end

    def add_gitignore
      gitignore_path = "#{@project_root}/.gitignore"
      if File.exist?(gitignore_path)
        ignores = IO.read(gitignore_path)
        has_ignore = ignores.include?("ufo/output")
        ignores << ufo_ignores unless has_ignore
      else
        ignores = ufo_ignores
      end
      IO.write(gitignore_path, ignores)
    end

    def ufo_ignores
      ignores =<<-EOL
ufo/output
ufo/docker_image_name*.txt
ufo/version
EOL
    end

  end
end

# http://stackoverflow.com/questions/1338960/ruby-templates-how-to-pass-variables-into-inlined-erb
class ERBContext
  def initialize(hash)
    hash.each_pair do |key, value|
      instance_variable_set('@' + key.to_s, value)
    end
  end

  def get_binding
    binding
  end
end
