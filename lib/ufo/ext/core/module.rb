class Module
  # Include all modules within the relative folder. IE: for dsl/syntax/mod/*
  #
  #    include Common
  #    include Provider
  #    # etc
  #
  # Caller lines are different for OSes:
  #
  #   windows: "C:/Ruby31-x64/lib/ruby/gems/3.1.0/gems/lono-1.1.1/lib/lono/builder.rb:34:in `build'"
  #   linux: "/home/ec2-user/.rvm/gems/ruby-3.0.3/gems/lono-1.1.1/lib/lono/compiler/dsl/syntax/mod.rb:4:in `<module:Mod>'"
  #
  def include_modules(dir)
    caller_line = caller[0]
    parts = caller_line.split(':')
    calling_file = caller_line.match(/^[a-zA-Z]:/) ? parts[1] : parts[0]
    parent_dir = File.dirname(calling_file)

    full_dir = "#{parent_dir}/#{dir}"
    # Tricky: Only include top-level dir. Do not include subdirs.
    # Fixes ruby 2.7 issue where just calling constantize on Vars::Builder
    # triggers Ufo::Config::CallableOption::Concern to load and causes
    # And causes some helper methods to be missing. Error looks like this:
    #
    #    undefined method `stack_output' for #<Ufo::Config:0x0000000006585268>
    #
    # This is because stack_output is loaded after afterwards.
    #
    paths = Dir.glob("#{full_dir}/*.rb")
    if paths.empty?
      raise "Empty include_modules full_dir: #{full_dir}"
    end

    paths.sort_by! { |p| p.size }
    paths.each do |path|
      regexp = Regexp.new(".*/lib/")
      mod = path.sub(regexp, '').sub('.rb','').camelize
      c = mod.constantize
      include c if c.class == Module
    end
  end
end
