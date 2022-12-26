require "erb"

# The results of compiling an ERB file.
class Build::ViewTemplate::ERBTemplate < Build::ViewTemplate
  def render
    ERB.new(contents, trim_mode: "-").result(compile_binding)
  end

  def output_pathname
    basename = input_pathname.basename.to_s.delete_suffix(".erb")
    dirname = input_pathname.dirname
    dirname/basename
  end
end
