require "pathname"

# TODO: come up with a better abstraction so compile_binding doesn't need to leak into here
# Probably a Component class that takes compile_binding and implements #render.
# Then components must define some method to return the ERB template contents.
class Header
  PATHNAME = Pathname.new(File.expand_path("./header.html.erb", __dir__))

  def initialize(compile_binding:)
    @compile_binding = compile_binding
  end

  def render
    ERB.new(PATHNAME.read, trim_mode: "-").result(compile_binding)
  end

  private

  attr_reader :compile_binding
end
