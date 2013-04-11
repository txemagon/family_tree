module FamilyTree

  module OutputType

    def self.output_types
      OutputType.constants.select { |c| Class === OutputType.const_get(c) } - [:AbstractOutput]
    end

    def self._class(name)
      
      name = name.to_s.capitalize.to_sym
      unless self.output_types.include? name
        raise FormatterError, "Formatter Error. Undefined class #{name.to_s}." 
      end

      OutputType.const_get name

    end

    class AbstractOutput

      @@initial_node
      @@relations_done 

      def start_with(initial_node)
        #raise FormatterError, "Formatter error. #{self.class.name} must redefine start_with method."
        unless initial_node.is_a? Relationship
          raise FormatterError, "Formatter Error. Initial node must be a relationship."
        end
        @@initial_node = initial_node

        process_relationship(initial_node)

      end

      def process_relationship(node)
        raise FormatterError, "Formatter Error. Expecting a relationship." unless node.is_a? Relationship
        puts "#{node.member[0].full_name} = #{node.member[1].full_name}" if node.member[0] and node.member[1]
        node.member.each do |m|
          process_person(m)
        end
        process_children(node.children)
      end
      
      def process_children(node)
        unless node.is_a? Relationship::Children
          raise FormatterError, "Formatter Error. Expecting children." 
        end
        node.each do |children|
          puts children.full_name
        end
      end

      def process_person(node)
        unless node.is_a? Person
          raise FormatterError, "Formatter Error. Expecting children." 
        end
        puts node.full_name
      end

    end

  end

end
