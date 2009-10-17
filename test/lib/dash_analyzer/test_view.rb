require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

setup_mongodb

class ViewTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
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
  
end