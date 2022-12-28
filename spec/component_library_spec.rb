require "lib/component_library"

RSpec.describe ComponentLibrary do
  describe "#compile_binding" do
    it "returns the instance binding" do
      klass = Class.new(described_class) do
        def value
          "in the binding"
        end
      end
      components = klass.new
      expect(components.compile_binding.eval("value")).to eq("in the binding")
    end
  end
end
