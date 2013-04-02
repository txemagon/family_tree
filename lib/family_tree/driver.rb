module FamilyTree
 module Driver

   def self.go(input, output_format)
     # Beautify the input
     lines = input.split("\n").map do |l| 
       l.gsub(/#.*$/, "").gsub(/^\s*$/, "") 
     end 
     lines = lines.select { |l| !l.empty? }
     output = lines.join("\n")
     $logger.info "Input processed to: #{output}"

     # Tokenize the string
     tokens = Lexer.new(output).start(output_format) do |output|
       puts output
     end

     # Parse tokens
     dom = Parser.crush(tokens, Relationship.new)

   end

 end

end
