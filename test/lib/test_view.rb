require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ViewTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  class MyApp < AbstractAnalyzer::View
    get "/index" do
      #"Session: #{session[:hello]}"
      "Hi!"
    end
    
    get "/show" do
      "Show me."
    end
  end
  
  def app
    MyApp.new
  end
  
  def test_index
    get "/index"
    
    assert last_response.ok?
    assert_equal last_response.body, "Hi!"
  end
  
  def test_show
    get "/show"
    
    assert last_response.ok?
    assert_equal last_response.body, "Show me."
  end
  
end