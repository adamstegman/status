require_relative "../lib/component_library"
require_relative "./components/atom"
require_relative "./components/head"
require_relative "./components/header"
require_relative "./components/footer"

# TODO: come up with a better abstraction so compile_binding doesn't need to leak into here
# Probably some DSL to construct components and pass in `compile_binding`.
# But what about other component arguments? They aren't present in the compile_binding.
# Would be great if components could take a block of ERB but I can't figure out how to do that.
class Components < ComponentLibrary
  def atom
    @atom ||= Atom.new
  end

  def head
    @head ||= Head.new
  end

  def header
    @header ||= Header.new(compile_binding: compile_binding)
  end

  def footer
    @footer ||= Footer.new(compile_binding: compile_binding)
  end
end
