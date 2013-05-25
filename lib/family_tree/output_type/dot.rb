require 'erb'

module FamilyTree

  module OutputType

    class Dot < AbstractOutput

      # Use @output instance variable as IO system
      def process_relationship(node)
        return if @relations_done.include? node
          super do |node|
            @output.print "\n\t{rank=same; " 
            node.member.each do |m|
              @output.print "#{m.full_name}; "
            end
            @output.print "R_#{node.id}; "
            @output.print "};\n"

            @output.puts "\tR_#{node.id} [label=\"\" shape=\"point\"];"
          end
      end


      def process_children(node)
        @output.puts "\n\t{rank=same;  #{node.collect{ |s| s.full_name}.join("; ") } };\n"
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
        edge[dir=none];
        node[shape=box, style=rounded];

<%= output %>

        }
        EOF
      end

      private

      def gender(name)
        puts ">> #{File.dirname(__FILE__)}"
        status = POpen4.popen4("vendor")
      end

    end

  end

end


