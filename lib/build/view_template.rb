# Builds content into the compiled site.
# Also includes a factory to find the right subclass based on file extension.
class Build::ViewTemplate
  class << self
    # Returns the class responsible for building the given Pathname, based on its extension.
    # Default option is to copy content exactly.
    def for_pathname(pathname)
      file_types[pathname.extname]
    end

    private

    # Maps file extensions to the class responsible for building those files.
    # Returns this class by default so the file is just copied.
    def file_types
      @file_types ||= Hash.new(self).merge(
        ".erb" => ERBTemplate,
      ).freeze
    end
  end

  def initialize(input_pathname:, contents:, compile_binding:)
    @input_pathname = input_pathname
    @contents = contents
    @compile_binding = compile_binding
  end

  # Subclasses should override to compile the contents into the output HTML.
  def render
    contents
  end

  # Subclasses should override to replace the extension with ".html".
  def output_pathname
    input_pathname
  end

  protected

  attr_reader :input_pathname, :contents, :compile_binding
end

require_relative "./erb_template"
