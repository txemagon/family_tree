module FamilyTree

  module DOM

    class Person
      attr_reader   :name
      attr_accessor :coming_from

      @@id       = 0
      @@list     = Hash.new
      @@preborns = Array.new

      class << self
        alias :__new__ :new
      end

      def self.new(*args, &block)
         $logger.debug "Creating person"
         begin
            obj = send :__new__, *args, &block
         rescue DOMUniqueness => e
           obj = self.find args[0][:name]
           $logger.debug "Create person was called for an existing one: #{args[0][:name]}."
         end
         obj
      end

      def self.find(name)
        raise DOMError, "DOM Error. Person #{} not found." unless @@list[name]
        @@list[name]
      end

      def self.sanitize(string)
        /^\$?([^@]*)/ =~ string
        $1
      end

      def sanitize(name)
        @name = Person.sanitize(name || @name)
      end

      def self.in_law?(name)
        name[0] == "$"
      end

      def self.names(collection)
        collection.collect { |p| p.name }
      end

      def self.qualified?(name)
       name =~ /.+@.+/
      end

      def self.surname(name)
       name =~ /.+@(.+)/
       $1
      end

      def self.virtualize
       @@preborns << (ticket = Person.born)
       ticket
      end

      def self.qualify(name)
        name + "@" + Person.virtualize
      end

      def plain_name
        @name =~ /[^@]+/
        $~
      end

      def full_name
        @name + "@" + @id
      end

      def initialize(params={})
        # Input errors
        raise ParserError, "Parse Error: Still no persons without Name. Name is required." unless params[:name]
        name = params[:name]
        raise ParserError, "Parse Error: Name is not a string"    if name and !name.is_a? String
        raise ParserError, "Parse Error: Name is an empty string" if name and !name.is_a? String

        if Person.qualified?(name) 
          $logger.debug "The name is: #{name}"
          @id = Person.surname(name)
        else
          @id = Person.born
        end
        
        sanitize(name)

        raise DOMUniqueness, "Parse Error: Full Name #{self.full_name} is already taken." if @@list.include? name 
        @@preborns.delete self.full_name if @@preborns.include? self.full_name
        @@list.merge!({self.full_name => self})

        #
        # @date_of_birth  = params[:date_of_birth]
        # @date_of_death  = params[:date_of_death]
        # @cause_of_death = params[:cause_of_death]
        # @comments       = params[:comments]
        $logger.debug "New person (#{@id}): #{@name ? @name : "anonymous"} created."

      end

      private 

      def self.born
        (@@id += 1).to_s
      end

    end

  end

end
