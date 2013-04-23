module FamilyTree
  module DOM

    class Relationship

      @@id = 0

      attr_accessor :children
      attr_reader :member, :id


      def initialize(params={})

        params[:members] ||= []
        params[:members].each do |m| 
          raise DOMError, "DOM Error. Invalid member name #{m.inspect}" unless m.is_a? String 
        end

        @id = @@id
        @@id += 1
        @start     = params[:start]
        @end       = params[:end]
        @children  = params[:children] || Relationship::Children.new(self)
        in_law     = in_blood = nil

        raise DOMError, "DOM Error: Too many progenitors" unless params[:members].size < 3

        @member    = params[:members].collect do |m| 
          p = Person.new(:name => m)
          begin
            if Person.in_law? m
              raise DOMError, "DOM Error: Too many in law relatives in #{params[:members]}" if in_law
              in_law = p 
            else
              raise DOMWarning, "DOM Warning: Too many blood relatives in #{params[:members]} use a dollar sign '$' in front of the name of one of the progenitors. i.e. $#{params[:members][0]}." if in_blood
              in_blood = p
            end
          rescue DOMWarning => e
            STDERR.puts e.message
          end
          p.marriages << self
          p
        end

        $logger.debug "New #{introduce} created."

        yield self, in_blood if in_blood

      end


      def introduce
        if @member.size == 2 and @member[0] and @member[1]
          "relationship between #{@member[0].name} and #{@member[1].name}"
        elsif (member = @member[0] || @member[1])
          "relation for #{member.name}"
        else
          "anonymous relationship"
        end
      end

      def children_names
        Person.names self.children
      end

    end
  end

end
