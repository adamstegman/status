require "fileutils"
require "logger"
require "pathname"

# The compiled assets of the website.
class Build
  attr_reader :destination

  def initialize(
    source: "content",
    destination: "_site",
    compile_binding: binding,
    cname: nil,
    logger:
  )
    @source = Pathname.new(File.expand_path("../#{source}", __dir__))
    @destination = Pathname.new(File.expand_path("../#{destination}", __dir__))
    @compile_binding = compile_binding
    @cname = cname
    @logger = logger
    @errors = {}
  end

  def build
    logger.debug { "[#{self.class.name}#build] source=#{source.inspect} destination=#{destination.inspect}" }
    clean_destination
    logger.debug { "[#{self.class.name}#build] source_pathnames=#{source_pathnames.inspect}" }
    source_pathnames.each(&method(:build_pathname))
    errors.each do |input_pathname, e|
      logger.error("ERROR: #{input_pathname}: #{e.message}")
    end
    abort if errors.any?
    write_cname
    logger.info("Built into '#{destination_relative}'!")
  rescue => e
    logger.debug { "[#{self.class.name}#build] [exception] #{error_log_message(e)}" }
    abort e.message
  end

  private

  attr_reader :source, :compile_binding, :cname, :logger, :errors

  def build_pathname(input_pathname)
    full_pathname = source/input_pathname
    return if full_pathname.directory?

    logger.info("Building '#{source_relative/input_pathname}'...")
    view_template = ViewTemplate.for_pathname(input_pathname).new(
      input_pathname: input_pathname,
      contents: full_pathname.read,
      compile_binding: compile_binding,
    )
    output_pathname = view_template.output_pathname
    logger.debug { "[#{self.class.name}#build_pathname] [input_pathname=#{input_pathname.inspect}] output_pathname=#{output_pathname.inspect}" }
    contents = view_template.render
    logger.debug { "[#{self.class.name}#build_pathname] [input_pathname=#{input_pathname.inspect}] contents=#{contents.inspect}" }
    destination_pathname = destination/output_pathname
    FileUtils.mkdir_p(destination_pathname.dirname)
    destination_pathname.write(contents)
    logger.info("Built '#{source_relative/input_pathname}' into '#{destination_relative/output_pathname}'!")
  rescue => e
    logger.debug { "[#{self.class.name}#build_pathname] [input_pathname=#{input_pathname.inspect}] [exception] #{error_log_message(e)}" }
    errors[input_pathname] = e
  end

  def clean_destination
    logger.info("Cleaning '#{destination_relative}'...")
    FileUtils.mkdir_p destination
    FileUtils.rm_f(cname_pathname)
    logger.debug { "[#{self.class.name}#clean_destination] [destination=#{destination.inspect}] contents=#{Dir.glob("#{destination}/**/*").inspect}" }
    Pathname.glob(destination/"**"/"*.html").each { |pathname|
      logger.debug { "[#{self.class.name}#clean_destination] [destination=#{destination.inspect}] [deleting] #{pathname.inspect}" }
      pathname.unlink
    }
    logger.info("Cleaned '#{destination_relative}'!")
  end

  def write_cname
    logger.debug { "[#{self.class.name}#write_cname] cname=#{cname.inspect}" }
    return unless cname

    cname_pathname.write(cname)
  end

  def cname_pathname
    destination/"CNAME"
  end

  def source_pathnames
    Pathname.glob("**/*", base: source)
  end

  def destination_relative
    destination.relative_path_from(project_root)
  end

  def source_relative
    source.relative_path_from(project_root)
  end

  def project_root
    File.expand_path("..", __dir__)
  end

  def error_log_message(e)
    "#{e.class.name}: #{e.message}\n#{clean_backtrace(e.backtrace).join("\n")}"
  end

  def clean_backtrace(backtrace)
    reversed_backtrace = backtrace.reverse
    last_index = reversed_backtrace.index { |line| line.include?(project_root) }
    reversed_backtrace[last_index..-1].reverse
  end
end

require_relative "./build/view_template"
