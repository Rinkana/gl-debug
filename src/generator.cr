p "##START##"
require "./generator/*"

xml = XML.parse(File.read "./generator/gl.xml")
core = Generator::Core.new(xml)

xml.xpath_nodes("registry/types/type").each do |type_node|
  next if %w(stddef khrplatform inttypes).includes?(type_node["name"]?.to_s) # Skip these types
  next if %w(gles1 gles2).includes?( type_node["api"]?.to_s ) # No need for older API's


  content = type_node.content.to_s
  name_node = type_node.xpath_node("name")

  if name_node
    def_name = name_node.content.to_s.strip
    ctype_name = content.chomp(def_name + ";").sub("typedef ","").strip
    p "#{def_name}::#{ctype_name}"
  else

  end

end

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
