module FamilyTree
 module Driver

   def self.go(input)
      lines = input.split("\n").map do |l| 
         l.gsub(/#.*$/, "").gsub(/^\s*$/, "") 
      end 
     lines = lines.select { |l| !l.empty? }
     output = lines.join("\n")
     $logger.debug "Input processed to: #{output}"
     Lexer.new(output).start
     output
   end
  
 end
 
end
