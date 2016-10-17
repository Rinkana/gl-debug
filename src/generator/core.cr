require "xml"

module Generator
  class Core
    getter :document
    getter :api

    getter commands : Hash(String, CommandEntry) = {} of String => CommandEntry
    getter types : Array(TypeEntry) = [] of TypeEntry

    def initialize(@document : XML::Node, @api = "gl")
      log("Booting generator")
      map_types
      collect_commands
    end

    def collect_commands(check_alias = true)
      log("Start to collect commands")
      @document.xpath_nodes("registry/commands/command").each do |cmd_node|
        next if check_alias && cmd_node.xpath_nodes("alias").size != 0
        proto_node = cmd_node.xpath_node("proto")

        unless proto_node.nil?
          map_entry = CommandEntry.new
          map_entry.api_name = (proto_node.xpath_node("name").try &.content).to_s

          proto_residue = proto_node.content.to_s
          proto_residue = proto_residue.sub(/const/, "").strip if proto_residue =~ /const/

          proto_ptype = proto_node.xpath_node("ptype")
          map_entry.ret_name = (proto_ptype ? proto_ptype.text.to_s.strip : proto_node.text.to_s.strip )
          map_entry.ret_name += " *" if proto_residue =~ /\*/

          cmd_node.xpath_nodes("param").each do |parameter_node|
            var_name = (parameter_node.xpath_node("name").try &.text).to_s.strip

            parameter_residue = parameter_node.content.to_s
            parameter_residue = parameter_residue.sub(/const/, "").strip if parameter_residue =~ /const/

            parameter_ptype = parameter_node.xpath_node("ptype")
            type_name = (parameter_ptype ? parameter_ptype.text.to_s.strip : parameter_node.text.to_s.strip)
            type_name += " *" if parameter_residue =~ /\*/ || parameter_residue =~/\[.+\]/

            map_entry.var_names << var_name
            map_entry.type_names << type_name
          end

          @commands[map_entry.api_name] = map_entry
        end
      end
      log("Command collecting done, found #{@commands.size} commands")
    end

    def filter_commands_for_api
      commands = {} of String => CommandEntry

      @document.xpath_nodes("registry/feature").each do |feature_node|
        if @api == feature_node["api"]?
          feature_node.xpath_nodes("require/command").each do |command|
            commands[command["name"].to_s] = @commands[command["name"]] if command["name"]
          end
        end
      end

      commands
    end

    def map_types
      log("Start mapping types")
      @types.clear

      @document.xpath_nodes("registry/types/type").each do |type_node|
        next if %w(stddef khrplatform inttypes).includes?(type_node["name"]?.to_s) # Skip these types
        next if %w(gles1 gles2).includes?( type_node["api"]?.to_s ) # No need for older API's

        name_node = type_node.xpath_node("name")

        content = type_node.content.to_s

        if name_node
          def_name = name_node.content.to_s.strip
          ctype_name = content.chomp(def_name + ";").sub("typedef ","").strip
        else
          # Fallback for types like 'GLhandleARB'
          def_name = type_node["name"]?.to_s
          ctype_name = "TODO"
        end

        type_entry = Generator::TypeEntry.new
        type_entry.def_name = def_name
        type_entry.ctype_name = ctype_name

        @types << type_entry
      end

      log("Done mapping types, mapped #{types.size} types")
      @types
    end


    def log(message)
      p "#{self.class.name}: #{message}"
    end
  end
end
