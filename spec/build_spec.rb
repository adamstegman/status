require "lib/build"

RSpec.describe Build do
  subject(:build) {
    described_class.new(source: "sourcedir", destination: "destdir", logger: logger)
  }
  let(:logger) { instance_double("Logger", error: nil, info: nil, debug: nil) }
  let(:absolute_path) { File.expand_path("..", __dir__) }
  before do
    allow(Pathname).to receive(:glob).and_return([])
    # Exception to bypass rescue StandardError in the class under test
    allow(File).to receive(:read) { |filename| raise Exception.new("Attempted to read '#{filename}'") }
    allow(File).to receive(:write)
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:rm_f)
    allow(build).to receive(:abort) { |msg = nil| raise "Aborted! msg=#{msg.inspect}" }
  end

  it "creates an HTML file for each input ERB file", :aggregate_failures do
    allow(Pathname).to receive(:glob).with("**/*", base: Pathname.new("#{absolute_path}/sourcedir")).and_return([
      Pathname.new("child/index.html.erb"),
      Pathname.new("index.html.erb"),
    ])
    allow(File).to receive(:read).with("#{absolute_path}/sourcedir/child/index.html.erb").and_return(<<~HTML)
      <html>
      <head><title><%= "CHILD" %></title></head>
      <body><%= 2.times.map { |i| "CHILD" + i.to_s }.join(", ") %></body>
      </html>
    HTML
    allow(File).to receive(:read).with("#{absolute_path}/sourcedir/index.html.erb").and_return(<<~HTML)
      <html>
      <head><title><%= "INDEX" %></title></head>
      <body><%= 2.times.map { |i| "INDEX" + i.to_s }.join(", ") %></body>
      </html>
    HTML

    build.build
    expect(File).to have_received(:write).with("#{absolute_path}/destdir/child/index.html", <<~HTML)
      <html>
      <head><title>CHILD</title></head>
      <body>CHILD0, CHILD1</body>
      </html>
    HTML
    expect(File).to have_received(:write).with("#{absolute_path}/destdir/index.html", <<~HTML)
      <html>
      <head><title>INDEX</title></head>
      <body>INDEX0, INDEX1</body>
      </html>
    HTML
  end

  it "copies other files", :aggregate_failures do
    allow(Pathname).to receive(:glob).with(
      "**/*",
      base: Pathname.new("#{absolute_path}/sourcedir"),
    ).and_return([
      Pathname.new("child"),
      Pathname.new("child/index.css"),
      Pathname.new("manifest.webmanifest"),
    ])
    # "child" is mocked as a directory to ensure it's not read
    allow_any_instance_of(Pathname).to receive(:directory?) do |this|
      this.to_s.end_with?("child")
    end
    allow(File).to receive(:read).with("#{absolute_path}/sourcedir/child/index.css").and_return("css")
    allow(File).to receive(:read).with("#{absolute_path}/sourcedir/manifest.webmanifest").and_return("{}")

    build.build
    expect(File).to have_received(:write).with("#{absolute_path}/destdir/child/index.css", "css")
    expect(File).to have_received(:write).with("#{absolute_path}/destdir/manifest.webmanifest", "{}")
  end

  context "when extra HTML files are in the destination" do
    it "removes leftover HTML files from the destination", :aggregate_failures do
      pathnames = [
        instance_double("Pathname", unlink: nil),
        instance_double("Pathname", unlink: nil),
      ]
      allow(Pathname).to receive(:glob).with(
        Pathname.new("#{absolute_path}/destdir/**/*.html"),
      ).and_return(pathnames)
      build.build
      pathnames.each do |pathname|
        expect(pathname).to have_received(:unlink)
      end
    end
  end

  context "when a CNAME is defined" do
    subject(:build) {
      described_class.new(
        source: "sourcedir",
        destination: "destdir",
        cname: "cname.example.com",
        logger: logger,
      )
    }

    it "creates a CNAME file" do
      build.build
      expect(File).to have_received(:write).with("#{absolute_path}/destdir/CNAME", "cname.example.com")
    end
  end

  context "when no CNAME is defined" do
    it "removes leftover CNAME from the destination" do
      build.build
      expect(FileUtils).to have_received(:rm_f).with(Pathname.new("#{absolute_path}/destdir/CNAME"))
    end
  end

  context "when an error occurs while processing" do
    before do
      allow(build).to receive(:abort)

      mock_build = instance_double("Build::FileType")
      mock_build_type = class_double("Build::FileType", new: mock_build)
      allow(Build::FileType).to receive(:for_pathname).and_return(mock_build_type)
      tries = 0
      allow(mock_build).to receive(:output_pathname) {
        tries += 1
        Pathname.new("#{tries}.html")
      }
      allow(mock_build).to receive(:compiled_contents) {
        raise "Compile error" if tries == 1
        "compiled contents"
      }
    end

    it "aborts after processing all files", :aggregate_failures do
      allow(Pathname).to receive(:glob).with("**/*", base: Pathname.new("#{absolute_path}/sourcedir")).and_return([
        Pathname.new("1.html.erb"),
        Pathname.new("2.html.erb"),
        Pathname.new("3.html.erb"),
      ])
      allow(File).to receive(:read).with("#{absolute_path}/sourcedir/1.html.erb")
      allow(File).to receive(:read).with("#{absolute_path}/sourcedir/2.html.erb")
      allow(File).to receive(:read).with("#{absolute_path}/sourcedir/3.html.erb")

      build.build
      expect(File).to have_received(:write).with("#{absolute_path}/destdir/2.html", "compiled contents")
      expect(File).to have_received(:write).with("#{absolute_path}/destdir/3.html", "compiled contents")
      expect(build).to have_received(:abort)
    end
  end
end
