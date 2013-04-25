require 'erb'

module FamilyTree

  module OutputType

    class Dot < AbstractOutput

      # Use @output instance variable as IO system
      def process_relationship(node)

        @output.puts "{rank=same;\n" 
        node.member.each do |m|
          @output.puts "#{m.full_name};\n"
        end
        @output.puts "R_#{node.id};\n"
        @output.puts "};\n"
        super do |node|
          @output.puts "\tR_#{node.id} [label=\"\" shape=\"point\"];"
        end
      end


      def process_children(node)
        @output.puts "{rank=same;\n #{node.collect{ |s| "#{s.full_name};" }.join("\n") } };\n"
        super
      end


      def process_person(node)
        super do |node|
          @output.puts "\t#{node.full_name} [label=\"#{node.name}\"];"
          @output.puts "\t#{node.full_name} -> R_#{node.coming_from.id} ;" if node.coming_from
          node.marriages.each do |m|
            @output.puts "\t#{node.full_name} -> R_#{m.id}[arrowsize=0];"
          end
        end
      end


      def template

        ERB.new <<-EOF
digraph {
        graph [rankdir=BT];
        edge[dir=none]
        node[shape=box, style=rounded];

<%= output %>

        }
        EOF
      end

    end

  end

end


