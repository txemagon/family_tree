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
         raise FormatterError, "Formatter error. #{self.class.name} must redefine start_with method."
      end

    end

  end

end
