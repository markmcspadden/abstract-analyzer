require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ViewTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  class MyApp < AbstractAnalyzer::TimeView
  end
  
  def app
    MyApp.new(HelloApp.new)
  end
  
  def test_index
    get "/index"
    
    assert last_response.ok?
    assert last_response.body.to_s.match(/Listing \d\d* Response Time Rollups/)
    assert last_response.body.to_s.match(/Total Calls/)
    assert last_response.body.to_s.match(/Total Time/)    
    assert last_response.body.to_s.match(/Avg Time per Call/)    
    
    puts last_response.body
  end
  
  def test_show
    get "/show"
    
    assert last_response.ok?
    assert_equal last_response.body, "Show me."
  end
  
end