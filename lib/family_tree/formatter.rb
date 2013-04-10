module FamilyTree

  ##
  # Formatter is a factory of class formatters defined in OutputType module

  class Formatter

    def self.new(output_type=:dot, *args, &block)
      output_type = class_symbol(output_type)
      $logger.debug "Output type #{output_type} selected."
      raise FormatterError, "Formatter Error. Undefined output type." unless OutputType::output_types.include? output_type
      OutputType._class(output_type).new
    end

    private

    def self.class_symbol(name)
      name.to_s.capitalize.to_sym
    end

  end


end
