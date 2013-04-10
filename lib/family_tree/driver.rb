module FamilyTree
 module Driver

   def self.go(input, lexer_format=:none, output_format=:dot)
     # Beautify the input
     lines = input.split("\n").map do |l| 
       l.gsub(/#.*$/, "").gsub(/^\s*$/, "") 
     end 
     lines = lines.select { |l| !l.empty? }
     output = lines.join("\n")
     $logger.info "Input processed to: #{output}"

     # Tokenize the string
     tokens = Lexer.new(output).start(lexer_format) do |output|
       puts output
     end

     # Parse tokens
     dom = Parser.crush(tokens, Relationship.new)

     # Write down the hierarchy
     logger_level = $logger.level
     $logger.level = Logger::DEBUG
     Formatter.new(output_format).start_with(dom)
     $logger.level = logger_level

   end

 end

end
