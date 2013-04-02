module Parser

  def Parser.crush(tokens, container)
    raise ParserError, "Parser Error: Invalid container." unless container.is_a? Relationship
    tokens.each do |token|
      container.children.push Person.new(:name => token[0])
    end
  end

end
