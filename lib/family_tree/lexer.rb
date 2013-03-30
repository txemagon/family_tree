require 'stringio'

module FamilyTree

  ##
  # This class is a finite automata that tokenizes a family tree in written down in
  # net format and returns a nested array of tokens. Each token is a subclass of Array.
  #
  # Instantiate the parser with the raw input and then start it. You can get a block with
  # the output in the format specified by the argument.

  class Lexer

    ENVIRONMENT   = %w/ single (marriage) [children] {parents} /

     def initialize(raw_input)
       @raw_input = raw_input
       @status = :person
     end

    ##
    # Start tokenizenig the input string.
    # xml and yaml supported by format
    # Whenever a valid format is supplied then a block is called
    # with the formatted string.
    #
    # Returns a nested array of tokens (DOM)

     def start(*args)
       if args and !args.empty?
         format = args.shift
         format = ("to_" + format.to_s).to_sym
       end
       list = split(StringIO.new @raw_input)
       $logger.info list.inspect.light_white
       yield(list.send(format)) if list.respond_to? format
       list
     end
  

     private

     ##
     # Recursive finite automata.
     # A valid grammar must be defined in the ENVIRONMENT constant.

     def split(band, state=Children, depth=0, chars_parsed=0)


       $logger.debug "Depth: #{depth.to_s} Chars: #{chars_parsed.to_s}".magenta
       $logger.debug "About to parse: #{band.string[chars_parsed..-1]}".magenta

       delimiter = ','.ord
       name = ""
       items = state.new
       $logger.debug "Created new Stack: '#{items.class.name}::#{items.inspect}'.".magenta

       stopper = state.stopper ? state.stopper.chr : nil
       starter = state.starter ? state.starter.chr : nil


       while(car = band.getbyte) do
         chars_parsed += 1
         $logger.debug "Processing: #{car.chr.light_yellow}".green

         if letter? car
           $logger.debug "LETTER".yellow
           name << car
         else
           if car == delimiter
             $logger.debug "SEPARATOR".yellow
             items.push name
             name = ""
           else 
             $logger.debug "DELIMITER".yellow
             if Token.have_starter? car
               scope = Token.starters[car]
               new_stopper = scope.stopper ? scope.stopper.chr : nil
               $logger.debug "New unit: #{scope.name} will end with '#{new_stopper}'"
               if !name.is_a? String or ( name.is_a? String and !name.strip.empty?)
                 items.push name
                 name = ""
               end
               name = split(band, scope, depth + 1, chars_parsed )
               $logger.debug "Result: " + "[#{name.inspect}]".light_yellow
               $logger.debug "Back in stack: " + "#{items.inspect}".light_cyan
               $logger.debug "End of unit: #{state.name} will end with '#{state.stopper}'. Current char: '#{car.chr}'"
             end
             if Token.have_stopper? car
               unless  state.stopper == car
                 $logger.debug "Received '#{car.chr}'. Waiting for '#{stopper}' in #{state.name}.".light_yellow
                 raise MatchError, 
                   ("Match Error. Extra '#{car.chr}' " + 
                     "in character #{chars_parsed.to_s}. " + 
                     "Waiting for '#{stopper}'.").light_red
               end 
               $logger.debug "Reached '#{car.chr}'. End of unit '#{state.name}'."
               items.push name
               return items 

             end
           end
         end
       end 

       if depth > 0 
         raise UnterminatedString, 
               "Missing delimiters. Parsing finished with depth = '#{depth.to_s}'.".light_red
       end
       items.push name unless name.empty?# flush the last name
       items

     end
  end

end
