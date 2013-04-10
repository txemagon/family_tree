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
            container.children.push kinsman unless container.children.include?(kinsman)
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


  def Parser.parse_marriage(items, over=false, &block)
    progenitors = Progenitors.new
    progenitors.over! if over
    children = FamilyTree::Children.new

    items.each do |item|
      $logger.debug "Token: #{item} [#{item.class.name}]"
      case item
      when FamilyTree::Single, FamilyTree::Marriage
        progenitors << item
      when FamilyTree::Children
        children += item
      end
    end

    $logger.debug "Singles: #{progenitors.singles}" 
    if progenitors.divorces?
      the_single = progenitors.get_single 
      the_single[0] = Person.qualify(the_single[0]) unless Person.qualified? the_single[0]

      $logger.debug "Found divorces for #{the_single}"

      progenitors.get_marriages.each do |m|
        m = m.dup
        m[0][0] = "$" + m[0][0] unless m[0][0].start_with? "$"
        m.unshift(the_single)
        $logger.debug "Divorce: #{m.inspect}"
        Parser.parse_marriage(m, true, &block)
      end
    end

    yield progenitors.singles, children if progenitors.together?

  end

end
