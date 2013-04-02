module FamilyTree

  module DOM

    class Person

      attr_reader   :name
      attr_accessor :comming_from

      @@id = 0

      def self.sanitize(string)
        /^\$?(.*)/ =~ string
        $1
      end

      def self.in_law?(name)
        name[0] == "$"
      end

      def self.names(collection)
        collection.collect { |p| p.name }
      end

      def initialize(params={})
        raise ParserError, "Parse Error: Name is not a string" if params[:name] and !params[:name].is_a? String
        @id = @@id
        @@id += 1
        @name           = Person.sanitize(params[:name])
        @date_of_birth  = params[:date_of_birth]
        @date_of_death  = params[:date_of_death]
        @cause_of_death = params[:cause_of_death]
        @comments       = params[:comments]
        $logger.debug "New person #{@name ? @name : "anonymous"} created."
      end

    end

  end

end
