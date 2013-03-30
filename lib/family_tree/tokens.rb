module FamilyTree


  module Tokens

    def letter?(char)
      (/[\$_a-zA-Z\s]/ =~ char.chr) != nil 
    end

    class Token < Array

      OUTPUT_FORMAT = %w{ yaml xml }.collect{ |x| x.to_sym }

      @@starters = Hash.new
      @@stoppers = Hash.new

      class << self
        attr_accessor :starter, :stopper
      end

      def format?(value)
        OUTPUT_FORMAT.include? value.to_sym
      end

      def Token.output_formats
        OUTPUT_FORMAT
      end

      def class_name
        self.class.name.split(/::/).last.downcase
      end

      def to_xml()
         output = ""
         output << "<" + class_name + ">\n"
         self.each do |child| 
            if child.respond_to? :to_xml
               child.to_xml.each_line do |l|
                 output << "  " + l
               end
            else
              output << "  " + child.to_s + "\n"
            end
         end
         output << "</" + class_name + ">\n"
         output
      end

      def to_yaml
        # todo: Develop yaml output
        raise "Still under development."
      end

      def push(name)
        
        person = (name.is_a? String)? Single.new(name.strip) : name.dup
        $logger.debug "Adding: '#{person.to_s.light_white}' to the current stack [#{self.class.name.light_white}].".light_magenta
        self << person
        name.clear if name.is_a? String
        $logger.debug "current Stack: #{self.inspect}".light_cyan
      end

      def initialize(*args)
        super()
        args.each { |item| self << item }
      end

      def self.create(token_name)
        first = token_name.chr
        unless (letter? first)
          last  = token_name.reverse.chr
          raise TokenError, "Uncomplete token definition. No match for '#{first}' in token '#{token_name}'.".light_red if letter? last
          token_name.chop!.reverse!.chop!.reverse!
          first = first.ord 
          last  = last.ord  
        else
          first = last = nil
        end

        new_token = Class.new(Token) do |toklass| 
          toklass.starter = first
          toklass.stopper = last
        end

        self.add_token(token_name, new_token, first, last)
        return [token_name.to_sym, new_token]
      end

      def Token.initiators
        Token.starters.keys
      end

      def Token.terminators
        Token.stoppers.keys
      end

      def Token.starters
        @@starters
      end

      def Token.stoppers
        @@stoppers
      end

      def Token.method_missing(meth, *args, &block)
        if (meth.to_s =~ /^have_(.+)\?/)
          set = case $1
                when /starter/
                  @@starters
                when /stopper/
                  @@stoppers
                end
          return set.include? args[0]
        end
      end

      private

      def self.add_token(class_name, klass, init=:default, ender=:default)
        # The same separator is allowed for init and end
        raise TokenError, "'#{init.chr.light_white}' already has been taken as an init separator in '#{class_name.light_white}'.".light_red if @@starters[init]
        raise TokenError, "'#{ender.chr.light_white}' already has been taken as an end separator in '#{class_name.light_white}'.".light_red  if @@stoppers[ender]
        Token.starters[init]  = klass
        Token.stoppers[ender] = klass
      end

    end


    def self.included(receiver)

      Lexer::ENVIRONMENT.each do |token|
        new_token = Token.create token
        FamilyTree.const_set new_token[0].capitalize, new_token[1]
      end

    end

  end
end
