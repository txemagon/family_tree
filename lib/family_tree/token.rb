module FamilyTree

  module Token

    def self.included(receiver)

      Parser::ENVIRONMENT.each do |token|
        self.const_set token.capitalize, Class.new(Array)
      end

    end

  end

end
