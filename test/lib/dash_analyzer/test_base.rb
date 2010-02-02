require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class BaseTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def setup
    setup_mongodb
  end

  class MyApp < DashAnalyzer::Base
        
    Fiveruns::Dash.register_recipe :testpack, :url => 'http://example.org' do |recipe|
      Fiveruns::Dash.logger.info 'REGISTERING ACTIONPACK RECIPE'
      recipe.time :response_time, :method => 'DashAnalyzer::Base#call', :mark => true
      recipe.time :another_response_time, :method => 'DashAnalyzer::Base#call', :mark => true
    end
    
    def initialize(*)
      @recipes = [{:name => :testpack, :url => 'http://example.org'}]
      super
    end  
  end
  
  def app
    MyApp.new(FooApp.new, 1)
  end

  def test_success
    get "/foo"
    
    assert last_response.ok?
  end
  
  # Should I really be testing Dash internals? I think not.
  def x_test_session_data_store
    5.times do
      get "/foo"
    end
     
    # Not really sure what this is all about, but I got it to work
    data = Fiveruns::Dash.session.data
    
    assert_equal 5, data.first[:values].first[:invocations]
    
    7.times do
      get "/foo"
    end
    
    # OK. Accessing the session data clears it out.
    data2 = Fiveruns::Dash.session.data
    assert_equal 7, data2.first[:values].first[:invocations]
  end
  
    
end