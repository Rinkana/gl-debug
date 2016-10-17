p "##START##"
require "./generator/*"

xml = XML.parse(File.read "./generator/gl.xml")
core = Generator::Core.new(xml)

if false
  commands = core.filter_commands_for_api

  file = File.open("./gl.cr", "wb") do |file|
    file << "ifdef darwin\n"
    file << "  @[Link(framework: \"OpenGL\")]\n"
    file << "else\n"
    file << "  @[Link(\"GL\")]\n"
    file << "end\n"

    file << "lib GL\n"

    commands.each do |key, command|
      file << "  fun #{command.api_name} = \"#{command.api_name}\"() : Void\n"
    end

    file << "end"
  end
end
p "##END##"
