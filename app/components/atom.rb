require "pathname"

class Atom
  PATHNAME = Pathname.new(File.expand_path("./atom.html", __dir__))

  def render
    @rendered ||= PATHNAME.read
  end
end
