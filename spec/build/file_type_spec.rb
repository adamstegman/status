require "lib/build"
require "lib/build/file_type"

RSpec.describe Build::FileType do
  describe "::for_pathname" do
    it "returns ERBFile for an ERB file" do
      expect(described_class.for_pathname(Pathname.new("input.html.erb"))).to be(Build::FileType::ERBFile)
    end

    it "returns FileType for other files" do
      expect(described_class.for_pathname(Pathname.new("input.css"))).to be(Build::FileType)
    end
  end
end
