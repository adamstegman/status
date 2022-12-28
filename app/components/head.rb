require "pathname"

class Head
  PATHNAME = Pathname.new(File.expand_path("./head.html", __dir__))

  def render
    @rendered ||= PATHNAME.read
  end
end
