require 'stringio'

module FamilyTree

  class Parser

     def initialize(raw_input)
       @raw_input = raw_input
     end

     def start
       siblings @raw_input
     end
    
     def siblings list
       list = split(list)
       $logger.debug "Siblings found: #{list.inspect}"
     end

     private

     def split list
      band = StringIO.new list
      name = ""
      items = []
      delimiter = ','
      while(car = band.getc) do
        case car
	    when delimiter then
	      items << name 
	      name = "" 
	      delimiter = ','
	    when '('
	      delimiter = ')'
            else
		name << car
	    end
      #list.split(",").collect { |name| name.strip }
     end 

     items
     end
  end

end
