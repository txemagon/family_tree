module FamilyTree
  module Parser

    @@last = nil

    def Parser.crush(token, container)

      $logger.debug "Entering Children Environment for #{token} [#{token.class.name}]"
      raise ParserError, "Parser Error: Invalid container." unless container.is_a? Relationship

      case token

        when FamilyTree::Single
          container.children.push(@@last = Person.new(:name => token[0]))

        when FamilyTree::Marriage
          Parser.parse_marriage(token) do |progenitors, children|
            $logger.debug "Reentering Children Environment in a Marriage."
            $logger.debug "Progenitors: #{progenitors.singles}"
            $logger.debug "Children: #{children}"
            Relationship.new(:members => progenitors.singles)  do |relationship, kinsman, in_blood_progenitors, in_law, in_law_progenitors|
              container.children.push kinsman unless container.children.include?(kinsman)
              $logger.debug "New sibling #{kinsman.name} added to #{Person.names container.children}."
              Parser.crush(children, relationship)
              if in_law
                if in_law_progenitors
                  $logger.debug "New branch in #{ in_law.name }" 
                  children = FamilyTree::Children.new
                  member = []
                  in_law_progenitors.each do |element| 
                    member << element[0] if element.is_a? FamilyTree::Single
                    children.concat(element) if element.is_a? FamilyTree::Children
                  end 
                  r = Relationship.new(:members => member)
                  r = Parser.crush(children, r)    
                  r.children.push in_law
                end
              end
              @@last = kinsman
            end
            if progenitors.members[0].progenitors
              $logger.debug "Parents in a Marriage [#{progenitors.members[0].progenitors.class.name}]"
              Parser.crush(progenitors.members[0].progenitors, container)
            end
          end

        when FamilyTree::Parents
          $logger.debug "Parsing parents:  #{token}"
          Parser.parse_marriage(token) do |progenitors, children|
            $logger.debug "Reentering Children Environment for Parents."
            $logger.debug "Progenitors: #{progenitors.members}"
            $logger.debug "Children: #{children}"
            r = container.reinitialize(:members => progenitors.singles) do |relationship, kinsman, in_blood_progenitors, in_law, in_law_progenitors|
              $logger.debug "In blood progenitors: #{in_blood_progenitors}"
              if in_blood_progenitors
                $logger.debug "new branch in #{ in_blood_progenitors }" 
                last = @last
                @last = kinsman
                $logger.debug "Kinsman #{kinsman.name}"
                r = Relationship.new
                c = Parser.crush(in_blood_progenitors, r)
                r.children.push kinsman
                @last = last
              end
              if in_law_progenitors
                $logger.debug "new branch in #{ in_law_progenitors }" 
                last = @last
                @last = in_law
                $logger.debug "In law #{in_law.name}"
                r = Relationship.new
                c = Parser.crush(in_law_progenitors, r)
                r.children.push in_law
                @last = last
              end
              #relationship.children << @@last
              Parser.crush(children, relationship)
              $logger.debug "new parental group. #{relationship.introduce}."
            end
            $logger.debug "added #{@@last.name} with siblings #{r.children_names}."
          end

        when FamilyTree::Children
          token.each { |element| Parser.crush(element, container) }
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
        when FamilyTree::Marriage
          progenitors << item
        when FamilyTree::Children
          children.concat(item)
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
