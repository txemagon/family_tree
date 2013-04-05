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

  class Progenitors

    def initialize(member=nil)
      @members = Array.new
      @singles = 0
      @divorced = false
      @members.push(member) if member
      @marriages = []
      @over = false
    end

    def <<(member)
      if member.is_a? FamilyTree::Single
        @singles += 1 
      else
        @divorced = true
      end

      raise ParserError, "Parsing Error. Divorces are not allowed inside a divorce. Use a separate branch and use @ sign lo link branches." if @over and member.is_a? FamilyTree::Marriage
      raise ParserError, "Parsing Error. Invalid type of progenitor." unless member.is_a? FamilyTree::Single or member.is_a? FamilyTree::Marriage
      raise ParserError, "Parsing Error. Too many progenitors." if @singles > 2

      @members << member
      @marriages << member if member.is_a? FamilyTree::Marriage

    end

    def over!
      @over = true
    end

    def get_single
      raise ParserError, "Parser Error. No single found." if @singles < 1
      main_single = @members.inject(nil) do |m, el| 
        new_value = nil
        new_value = el if el.is_a? FamilyTree::Single and !el[0].start_with? "$" 
        if (m and new_value)
          raise ParserError, "Parser Error. Undefined main single for the relationship. Use $ to debase one of the members. Otherwise I won't know who to assign divorces." if @singles == 2 and main_single == nil
        end
        new_value ? new_value : m
      end
      $logger.debug "main single: #{main_single}"
      main_single
    end

    def singles
      raise ParserError, "Parser Error. Several marriages for this person." if @singles != 2
      (@members - @marriages).map { |m| m[0] }
    end

    def get_marriages
      @marriages
    end

    def divorces?
      @divorced
    end

    def together?
      @singles == 2
    end

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

    if progenitors.divorces?

      $logger.debug "Found divorces for #{progenitors.get_single}"
      progenitors.get_marriages.each do |m|
        m = m.dup
        m[0][0] = "$" + m[0][0] unless m[0][0].start_with? "$"
        # todo: Make a reference for the single in order to avoid double inclusion
        # as a sibling (one for each divorce)
        m.unshift(progenitors.get_single)
        $logger.debug "Divorce: #{m.inspect}"
        Parser.parse_marriage(m, true, &block)
      end
    end

    yield progenitors.singles, children if progenitors.together?

  end

end
