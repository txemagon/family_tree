module FamilyTree

  module DOM

    class Relationship

      class Children < Array

        @relationship 
        attr_reader :relationship

        def initialize(owner)
          @relationship = owner
        end

        def push(person)
          unless person.respond_to? :coming_from
            raise DOMError, "#{person} doesn't respond to coming_from method." 
          end
          person.coming_from = @relationship
          super
        end
      end

    end

  end

end
