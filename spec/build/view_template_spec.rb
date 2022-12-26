require "lib/build"
require "lib/build/view_template"

RSpec.describe Build::ViewTemplate do
  describe "::for_pathname" do
    it "returns ERBTemplate for an ERB file" do
      expect(described_class.for_pathname(Pathname.new("input.html.erb"))).to be(Build::ViewTemplate::ERBTemplate)
    end

    it "returns ViewTemplate for other files" do
      expect(described_class.for_pathname(Pathname.new("input.css"))).to be(Build::ViewTemplate)
    end
  end
end
