require 'erb'

module FamilyTree

  module OutputType

    class Dot < AbstractOutput

      # Use @output instance variable as IO system
      def process_relationship(node)
        @output.puts "subgraph Marriage_#{node.id}{ \n"
        super do |node|
          @output.puts "\tR_#{node.id} [label=\"\" shape=\"point\"];"
        end
        @output.puts "\n}"
      end


      def process_children(node)
        @output.puts "subgraph Children_#{node.relationship.id}{ \n"
        super
        @output.puts "\n}"
      end


      def process_person(node)
        super do |node|
          @output.puts "\t#{node.full_name} [label=\"#{node.name}\"];"
          @output.puts "\t#{node.full_name} -> R_#{node.coming_from.id} ;" if node.coming_from
          node.marriages.each do |m|
            @output.puts "\t#{node.full_name} -> R_#{m.id};"
          end
        end
      end


      def template

        ERB.new <<-EOF
digraph {
        graph [rankdir=BT, splines=ortho];

<%= output %>

        }
        EOF
      end

    end

  end

end


