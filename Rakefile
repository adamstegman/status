desc "Creates the component library"
task :components do |task|
  require_relative "app/components"
  COMPONENTS = Components.new
end

desc "Build the site from ERB files in content/ into the _site/ directory. Set CNAME to write a CNAME file. Set DEBUG for debug logging. Set `COMPONENTS` constant with your component library, which should inherit from `ComponentLibrary`."
task :build => :components do |task|
  require "logger"
  logger = Logger.new(STDOUT)
  logger.level = ENV["DEBUG"] ? Logger::DEBUG : Logger::INFO

  require_relative "lib/build"
  opts = {}
  opts[:cname] = ENV["CNAME"] if ENV["CNAME"]
  opts[:compile_binding] = COMPONENTS.compile_binding if defined? COMPONENTS
  build = Build.new(logger: logger, **opts)
  build.build
end

require "static_deploy"
ENV["GENERATOR"] = "rake"
ENV["COMMAND"] = "build"
