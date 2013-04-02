module Parser

  @@last = nil

  def Parser.crush(tokens, container)

    raise ParserError, "Parser Error: Invalid container." unless container.is_a? Relationship

    tokens.each do |token|
      case token

      when FamilyTree::Single
        container.children.push(@@last = Person.new(:name => token[0]))

      when FamilyTree::Marriage
        Parser.parse_marriage(token) do |progenitors, children|
          Relationship.new(:members => progenitors)  do |relationship, kinsman|
            container.children.push kinsman
            Parser.crush(children, relationship)
            $logger.debug "New sibling #{kinsman.name} added to #{Person.names container.children}."
          end

        end

      when FamilyTree::Parents
        Parser.parse_marriage(token) do |progenitors, children|
          r = Relationship.new(:members => progenitors)  do |relationship, kinsman|
            relationship.children << @@last
            Parser.crush(children, relationship)
            $logger.debug "New parental group. #{relationship.introduce}."
          end
          $logger.debug "Added #{@@last.name} with siblings #{r.children_names}."
        end

      end
    end
    container
  end

  private

  def Parser.parse_marriage(items)
    progenitors = []
    children = []
    items.each do |item|
      progenitors << item[0] if item.is_a? FamilyTree::Single
      children = item if item.is_a? FamilyTree::Children
    end
    yield progenitors, children
  end

end
