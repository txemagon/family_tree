module FamilyTree
  module DOM

    class Relationship

      @@id = 0

      attr_accessor :children
      attr_reader :member, :id


      def add_members(members)
        raise DOMError, "DOM Error. Relationship members were alreadys set." unless @member.empty?
        @member = members
      end

      def add_member(member)
        member = Person.new member if (member.is_a? String)
        member = Person.new member[0] if (member.is_a? FamilyTree::Single)
        unless member.is_a? Person
          raise DOMError, "DOM Error. Invalid member type for #{member} [#{member.class.name}]"
        end
        raise DOMError, "DOM Error. Too many relationship components." unless @member.size < 2
        @member << member
      end


      def initialize(params={}, fake=false)

        params[:members] ||= []
        params[:members].each do |m| 
          raise DOMError, "DOM Error. Invalid member name #{m.inspect}" unless m.is_a? String 
        end

        unless fake
          @id = @@id
          @@id += 1
        end
        @start     = params[:start]
        @end       = params[:end]
        @children  = params[:children] || Relationship::Children.new(self)
        in_law     = in_law_progenitors = in_blood = in_blood_progenitors = nil

        raise DOMError, "DOM Error: Too many progenitors" unless params[:members].size < 3

        @member    = params[:members].collect do |m| 
          if m.include?("#")
            m =~ /(.*)#(.*)/m
            m = $1
            progenitors = $2
          end
          p = Person.new(:name => m)
          begin
            if Person.in_law? m
              raise DOMError, "DOM Error: Too many in law relatives in #{params[:members]}" if in_law
              in_law = p 
              in_law_progenitors = Marshal.load(progenitors) if progenitors
            else
              raise DOMWarning, "DOM Warning: Too many blood relatives in #{params[:members]} use a dollar sign '$' in front of the name of one of the progenitors. i.e. $#{params[:members][0]}." if in_blood
              in_blood = p
              if progenitors
                if in_blood_progenitors
                  raise DOMError, "DOM Errors. No main branch. Use a $ in front of one of the progenitors. i.e. $#{p.name}"
                end
                in_blood_progenitors = Marshal.load(progenitors) 
              end
            end
          rescue DOMWarning => e
            STDERR.puts e.message
          end
          p.marriages << self
          p
        end

        $logger.debug "New #{introduce} created."

        yield self, in_blood, in_blood_progenitors, in_law, in_law_progenitors if in_blood and block_given?

      end


      def reinitialize(*args, &block)
        children = @children
        initialize *args, &block
        @children = children.concat @children
        return self
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
