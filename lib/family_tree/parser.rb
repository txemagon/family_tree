module FamilyTree
  module Parser

    @@last = nil

    def Parser.crush(tokens, container)

      $logger.debug "Entering Children Environment for #{tokens}"
      raise ParserError, "Parser Error: Invalid container." unless container.is_a? Relationship

      tokens.each do |token|
        case token

        when FamilyTree::Single
          container.children.push(@@last = Person.new(:name => token[0]))

        when FamilyTree::Marriage
          Parser.parse_marriage(token) do |progenitors, children|
            $logger.debug "Reentering Children Environment in a Marriage."
            $logger.debug "Progenitors: #{progenitors.singles}"
            $logger.debug "Children: #{children}"
            Relationship.new(:members => progenitors.singles)  do |relationship, kinsman, in_law, in_law_progenitors|
              if kinsman
                container.children.push kinsman unless container.children.include?(kinsman)
                $logger.debug "New sibling #{kinsman.name} added to #{Person.names container.children}."
              end 
              Parser.crush(children, relationship)
              if in_law
                if in_law_progenitors
                  $logger.debug "New branch in #{ in_law.name }" 
                  children = FamilyTree::Children.new
                  member = []
                  in_law_progenitors.each do |element| 
                      member << element[0] if element.is_a? FamilyTree::Single
                      children += element if element.is_a? FamilyTree::Children
                  end 
                  r = Relationship.new(:members => member)
                  r = Parser.crush(children, r)    
                  r.children.push in_law
                end
              end
            end
          end

        when FamilyTree::Parents
          Parser.parse_marriage(token) do |progenitors, children|
            $logger.debug "Reentering Children Environment for Parents."
            $logger.debug "Progenitors: #{progenitors}"
            $logger.debug "Children: #{children}"
            r = container.reinitialize(:members => progenitors.singles)  do |relationship, kinsman|
              # todo: If some of the members of the relationsip has progenitors try
              # to make a new branch and connect it with this one              
              progenitors.members.each do |member|
                $logger.debug "New branch in #{ member.progenitors }" if member.progenitors
              end
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

    ## This methods normalizes the complexity of a Marriage but its not the parser itself
    def Parser.parse_marriage(items, over=false, &block)
      $logger.debug "Entering Marriage Environment for #{items}"
      progenitors = Progenitors.new
      progenitors.over! if over
      children = FamilyTree::Children.new

      items.each do |item|
        $logger.debug "Token: #{item} [#{item.class.name}]"
        case item
        when FamilyTree::Single
          progenitors << item
          #@@last = DOM::Person.new(:name => item[0])
        when FamilyTree::Marriage
          progenitors << item
        when FamilyTree::Children
          children += item
        when FamilyTree::Parents
          progenitors.connect_with(item)
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

      # yield progenitors.singles, children if progenitors.together?
      yield progenitors, children

    end

  end

end
