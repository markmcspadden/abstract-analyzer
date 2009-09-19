require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

  class MyApp < HelloWorld

  end
  
  def app
    MyApp.new
  end

  def test_success
    get "/foo"
    
    assert last_response.ok?
  end
end