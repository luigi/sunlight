module Sunlight

  class Issue < Base
    attr_accessor :code, :specific_issue

    # Takes in a hash where the keys are strings (the format passed in by the JSON parser)
    #
    def initialize(params)
      params.each do |key, value|    
        instance_variable_set("@#{key}", value) if Issue.instance_methods.include? key
      end
    end
  end

end