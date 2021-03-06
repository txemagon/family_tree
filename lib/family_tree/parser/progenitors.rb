module FamilyTree
  module Parser

    private

    class Progenitors

      attr_reader :members

      def initialize(member=nil)
        @members = Array.new
        @singles = 0
        @divorced = false
        @members.push(member) if member
        @marriages = []
        @over = false
        @last = nil
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

        @members << (@last = member)
        @marriages << member if member.is_a? FamilyTree::Marriage
      end

      def connect_with(progenitors)
        raise ParserError, "Parsing Error. Progenitors are only allowed for singles." unless @last.is_a? FamilyTree::Single
        @last.progenitors = progenitors
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
        (@members - @marriages).map do |m| 
          if m.progenitors and !m.progenitors.empty?
            "#{m[0]}##{Marshal.dump(m.progenitors)}" 
          else
            m[0]
          end
        end
      end

      def names
        (@members - @marriages).map do |m|
          m[0]
        end
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
  end
end

