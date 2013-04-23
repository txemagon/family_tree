module FamilyTree

  module OutputType

    class Dot < AbstractOutput

      def process_relationship(node)
        super do |node|
          puts "\tR_#{node.id};"
        end
      end


      def process_children(node)
        super
      end


      def process_person(node)
        super do |node|
          puts "\t#{node.name};"
        end
      end


      def initialize
        puts "digraph {\n"
      end

    end

  end

end


