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
    @members = Array.new
    @singles = 0

    def initialize(member)
      @members.push(member) if member
    end

    def <<(member)
      @singles += 1 if member.is_a? Single
      raise ParserError, "Parsing Error. Invalid type of progenitor." unless member.is_a? Single or member.is_a? Marriage
      raise ParserError, "Parsing Error. Too many progenitors." if @singles > 2
      @members << member
    end

  end

  def Parser.parse_marriage(items)
    progenitors = []
    children = FamilyTree::Children.new
    items.each do |item|
      case item
      when FamilyTree::Single
        progenitors << item[0]
        raise ParserError, "Parsing Error. Too many progenitors." if progenitors.size > 2
      when FamilyTree::Children
        children += item
      when FamilyTree::Marriage
        raise ParserError, "Parsing Error. Too many progenitors." if progenitors.size > 2
      end
    end
    yield progenitors, children
  end

end
