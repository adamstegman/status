desc "Build the site from ERB files in content/ into the _site/ directory. Set CNAME to write a CNAME file. Set DEBUG for debug logging."
task :build do |task|
  require "logger"
  logger = Logger.new(STDOUT)
  logger.level = ENV["DEBUG"] ? Logger::DEBUG : Logger::INFO
  require_relative "lib/build"
  build = Build.new(logger: logger, cname: ENV["CNAME"])
  build.build
end

require "static_deploy"
ENV["GENERATOR"] = "rake"
ENV["COMMAND"] = "build"
