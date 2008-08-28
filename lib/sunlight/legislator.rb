module Sunlight

  class Legislator < SunlightObject
    

    attr_accessor :title, :firstname, :middlename, :lastname, :name_suffix, :nickname,
                  :party, :state, :district, :gender, :phone, :fax, :website, :webform,
                  :email, :congress_office, :bioguide_id, :votesmart_id, :fec_id,
                  :govtrack_id, :crp_id, :event_id, :congresspedia_url
    
    # Takes in a hash where the keys are strings (the format passed in by the JSON parser)
    #
    def initialize(params)
      params.each do |key, value|    
        instance_variable_set("@#{key}", value) if Legislator.instance_methods.include? key
      end
    end
    
    
    
    #
    # Useful for getting the exact Legislators for a given district.
    #
    # Returns:
    #
    # A Hash of the three Members of Congress for a given District: Two
    # Senators and one Representative.
    #
    # You can pass in lat/long or address. The district will be
    # determined for you:
    #
    #   officials = Legislator.all_for(:latitude => 33.876145, :longitude => -84.453789)
    #   senior = officials[:senior_senator]
    #   junior = officials[:junior_senator]
    #   rep = officials[:representative]
    #
    #   Legislator.all_for(:address => "123 Fifth Ave New York, NY 10003")
    #   Legislator.all_for(:address => "90210") # not recommended, but it'll work
    #
    def self.all_for(params)
      
      if (params[:latitude] and params[:longitude])
        Legislator.all_in_district(District.get(:latitude => params[:latitude], :longitude => params[:longitude]))
      elsif (params[:address])
        Legislator.all_in_district(District.get(:address => params[:address]))
      else
        nil # appropriate params not found
      end
      
    end
    
    
    #
    # A helper method for all_for. Use that instead, unless you 
    # already have the district object, then use this.
    #
    # Usage:
    #
    #   officials = Legislator.all_in_district(District.new("NJ", "7"))
    #
    def self.all_in_district(district)
      
      senior_senator = Legislator.all_where(:state => district.state, :district => "Senior Seat").first
      junior_senator = Legislator.all_where(:state => district.state, :district => "Junior Seat").first
      representative = Legislator.all_where(:state => district.state, :district => district.number).first
            
      {:senior_senator => senior_senator, :junior_senator => junior_senator, :representative => representative}
      
    end
    
    
    #
    # A more general, open-ended search on Legislators than #all_for.
    # See the Sunlight API for list of conditions and values:
    #
    # http://services.sunlightlabs.com/api/docs/legislators/
    #
    # Returns:
    #
    # An array of Legislator objects that matches the conditions
    #
    # Usage:
    #
    #   johns = Legislator.all_where(:firstname => "John")
    #   floridians = Legislator.all_where(:state => "FL")
    #   dudes = Legislator.all_where(:gender => "M")
    #
    def self.all_where(params)
      
      url = construct_url("legislators.getList", params)
      
      if (result = get_json_data(url))
            
        legislators = []
        result["response"]["legislators"].each do |legislator|
          legislators << Legislator.new(legislator["legislator"])
        end
        
        legislators
      
      else  
        nil
      end # if response.class
      
    end
    
    
    
  end # class Legislator

end # module Sunlight