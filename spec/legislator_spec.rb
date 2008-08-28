require File.dirname(__FILE__) + '/spec_helper'

describe Sunlight::Legislator do
  
  before(:each) do

    Sunlight.api_key = 'the_api_key'
    @example_hash = {"webform"=>"https://forms.house.gov/wyr/welcome.shtml", "title"=>"Rep", "nickname"=>"", "eventful_id"=>"P0-001-000016482-0", "district"=>"4", "congresspedia_url"=>"http://www.sourcewatch.org/index.php?title=Carolyn_McCarthy", "fec_id"=>"H6NY04112", "middlename"=>"", "gender"=>"F", "congress_office"=>"106 Cannon House Office Building", "lastname"=>"McCarthy", "crp_id"=>"N00001148", "bioguide_id"=>"M000309", "name_suffix"=>"", "phone"=>"202-225-5516", "firstname"=>"Carolyn", "govtrack_id"=>"400257", "fax"=>"202-225-5758", "website"=>"http://carolynmccarthy.house.gov/", "votesmart_id"=>"693", "sunlight_old_id"=>"fakeopenID252", "party"=>"D", "email"=>"", "state"=>"NY"}

    @jan = Sunlight::Legislator.new({"firstname" => "Jan", "district" => "Senior Seat", "title" => "Sen"})  
    @bob = Sunlight::Legislator.new({"firstname" => "Bob", "district" => "Junior Seat", "title" => "Sen"})
    @tom = Sunlight::Legislator.new({"firstname" => "Tom", "district" => "4", "title" => "Rep"})

    @example_legislators = {:senior_senator => @jan, :junior_senator => @bob, :representative => @tom}
    
  end
  
  describe "#initialize" do
    
    it "should create an object from a JSON parser-generated hash" do
      carolyn = Legislator.new(@example_hash)
      carolyn.should be_an_instance_of Legislator
      carolyn.firstname.should eql "Carolyn"
    end
    
  end
  
  describe "#all_for" do
    
    it "should return nil when junk is passed in" do
      legislators = Sunlight::Legislator.all_for(:bleh => 'blah')
      legislators.should be nil
    end
    
    it "should return hash when valid lat/long are passed in" do
      Sunlight::Legislator.should_receive(:all_in_district).and_return(@example_legislators)
      
      legislators = Sunlight::Legislator.all_for(:latitude => 33.876145, :longitude => -84.453789)
      legislators[:senior_senator].firstname.should eql 'Jan'
      #@example_legislators[:senior_senator].firstname.should eql 'Jan'
    end
    
    it "should return hash when valid address is passed in" do
      Sunlight::Legislator.should_receive(:all_in_district).and_return(@example_legislators)
      
      legislators = Sunlight::Legislator.all_for(:address => "123 Fake St Anytown USA")
      legislators[:junior_senator].firstname.should eql 'Bob'
    end
        
  end
  
  describe "#all_in_district" do
    
    it "should return has when valid District object is passed in" do
      Sunlight::Legislator.should_receive(:all_where).exactly(3).times.and_return([@jan])
      
      legislators = Sunlight::Legislator.all_in_district(Sunlight::District.new("NJ", "7"))
      legislators.should be_an_instance_of Hash
      legislators[:senior_senator].firstname.should eql 'Jan'
    end
    
  end
  
  
  describe "#all_where" do
    
    it "should return array when valid parameters passed in" do
      Sunlight::Legislator.should_receive(:get_json_data).and_return({"response"=>{"legislators"=>[{"legislator"=>{"state"=>"GA"}}]}})
      
      legislators = Sunlight::Legislator.all_where(:first_name => "Susie")
      legislators.first.state.should eql 'GA'
    end
    
    it "should return nil when unknown parameters passed in" do
      Sunlight::Legislator.should_receive(:get_json_data).and_return(nil)
      
      legislators = Sunlight::Legislator.all_where(:blah => "Blech")
      legislators.should be nil
    end
    
  end
  
end