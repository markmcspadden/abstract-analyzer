require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ViewTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  class MyApp < AbstractAnalyzer::View
    # enable :sessions
    # 
    # get "/set1" do
    #   session[:hello] = "WIN!!"
    #   "Setting session"
    # end
    # 
    # get "/set2" do
    #   session[:hello] = "WIN AGAIN!!"
    #   "Setting session"
    # end
    # 
    # get "/get" do
    #   "Session: #{session[:hello]}"
    # end
  end
  
  def app
    MyApp.new
  end
  
  def test_index
    get "/index"
    
    assert last_response.ok?
    assert_equal last_response.body, "Hello world!"
  end
  
end