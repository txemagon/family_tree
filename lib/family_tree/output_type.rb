module FamilyTree

  module OutputType

    def self.output_types
      OutputType.constants.select { |c| Class === OutputType.const_get(c) } - [:AbstractOutput]
    end


    def self._class(name)
      
      name = name.to_s.capitalize.to_sym
      unless self.output_types.include? name
        raise FormatterError, "Formatter Error. Undefined class #{name.to_s}." 
      end

      OutputType.const_get name

    end


    class AbstractOutput

      def initialize
        @initial_node
        @people_done = []
        @relations_done = []
        @delayed_jobs = []
      end


      def start_with(initial_node, output=StringIO.new)

        #raise FormatterError, "Formatter error. #{self.class.name} must redefine start_with method."
        unless initial_node.is_a? Relationship
          raise FormatterError, "Formatter Error. Initial node must be a relationship."
        end
        @initial_node = initial_node
        @output = output

        process_relationship(initial_node)

        until @delayed_jobs.empty?
          job = @delayed_jobs.shift
          job.call()
        end

        output = @output.string.gsub(/\@/, "_")

        if self.respond_to? :template
          return template.result(binding)
        end
        return output

      end


      def process_relationship(node)

        raise FormatterError, "Formatter Error. Expecting a relationship." unless node.is_a? Relationship

        return if @relations_done.include? node
        @relations_done << node

        if node.member[0] and node.member[1]
           $logger.debug "#{node.member[0].full_name} <=> #{node.member[1].full_name}" 
        end
        yield node

        node.member.each do |m|
          process_person(m)
        end

        process_children(node.children)
        
      end

      
      def process_children(node)
        unless node.is_a? Relationship::Children
          raise FormatterError, "Formatter Error. Expecting children. Found #{node.class.name}" 
        end

        node.each do |children|
          process_person children
        end
      end


      def process_person(node)
        unless node.is_a? Person
          raise FormatterError, "Formatter Error. Expecting person. Found #{node.class.name}"
        end
        return if @people_done.include? node
        @people_done << node
        $logger.debug node.full_name
        process_relationship(node.coming_from) if node.coming_from
        yield node
        @delayed_jobs.push( Proc.new {node.marriages.each { |marr| process_relationship marr } } )
      end

    end

  end

end
