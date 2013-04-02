module FamilyTree

  module DOM

    class Person

      attr_accessor :comming_from

      def initialize(params={})
        @name           = params[:name]
        @date_of_birth  = params[:date_of_birth]
        @date_of_death  = params[:date_of_death]
        @cause_of_death = params[:cause_of_death]
        @comments       = params[:comments]
      end

    end

  end

end
