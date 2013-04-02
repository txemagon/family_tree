module FamilyTree
  module DOM

    class Relationship

      def initialize(params={})
        @start     = params[:start]
        @end       = params[:end]
        @children  = params[:children] || []
        @members   = params[:members]
      end

    end
  end

end
