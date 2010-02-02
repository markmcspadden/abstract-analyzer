require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ViewTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def setup
    setup_mongodb
  end
  
  class MyApp < DashAnalyzer::TimeView
  end
  
  def app
    MyApp.new(FooApp.new, 'testpack-response_time')
  end
  
  def test_index
    get "/analytics"
    
    assert last_response.ok?
       
    puts last_response.body
  end
  
  def test_show
    get "/analytics/show/testpack-response_time"
    
    assert last_response.ok?
  end
  
  
  # class ArApp < DashAnalyzer::Base          
  #   Fiveruns::Dash.register_recipe :testpack, :url => 'http://example.org' do |recipe|
  #     Fiveruns::Dash.logger.info 'REGISTERING ACTIONPACK RECIPE'
  #     recipe.time :response_time, :method => 'DashAnalyzer::Base#call', :mark => true
  #     recipe.time :another_response_time, :method => 'DashAnalyzer::Base#call', :mark => true
  #   end
  #   
  #   def initialize(*)
  #     @recipes = [{:name => :testpack, :url => 'http://example.org'}]
  #     super
  #   end  
  # end
  # 
  # def ar_app
  #   ArApp.new(FooApp.new, 1)
  # end
  
  # def test_activerecord_index
  #   setup_activerecord    
  #   
  #   get "/analytics"
  # 
  #   assert last_response.ok?
  # 
  #   puts last_response.body
  # end
  
end