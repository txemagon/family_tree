require 'stringio'

module FamilyTree

  class Parser

    ENVIRONMENT = %w{ person marriage children parents }

     def initialize(raw_input)
       @raw_input = raw_input
       @status = :person
     end

     def start
       siblings @raw_input
     end
    
     def siblings list
       list = split(list)
       $logger.debug "Siblings found: #{list.inspect}"
     end

     private

     def trigger car
        
     end

     def split list
      punctuator = [ ',', '(', ')']
      band = StringIO.new list  # Pretend the input is a stream
      name = ""
      items = []
      def items.push(name)      # Tag and Beautify tokens 
        self << name.strip
      end
      delimiter = ','
      group_unit = 0
      chars_parsed = 0
      while(car = band.getc) do
        chars_parsed += 1
        case car
            when ')'
              group_unit -= 1 
              name << car unless group_unit == 0 # Preserve inner parenthesis
              raise MatchError, "Extra ')' in character #{chars_parsed}." if group_unit < 0
	    when delimiter then
              if ( group_unit == 0)
	         items.push name
	         name = "" 
              else
                name << car # Preserve comma inside marriage units
              end
	    when '('
              name << car unless group_unit == 0
              group_unit += 1
            else
		name << car  # Preserve inner parenthesis
	    end
     end 

     items.push name # flush the last name
     raise UnterminatedString, "Parsing finished and #{group_unit} #{ group_unit == 1 ? "parenthesis was" : "parathenteses were" } still missing." if group_unit > 0
     items
     end
  end

end
