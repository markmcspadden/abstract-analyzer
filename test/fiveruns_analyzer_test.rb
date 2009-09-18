require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class FiverunsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  class HelloApp < HelloWorld
    
  end

  class MyApp < FiverunsAnalyzer::Logger

  end
  
  def app
    MyApp.new(HelloApp.new)
  end

  def test_success
    get "/foo"
    
    assert last_response.ok?
  end
  
  def test_log
    5.times do
      get "/foo"
    end
    
    # Not really sure what this is all about, but I got it to work
    data = Fiveruns::Dash.session.data
    
    assert_equal 5, data.first[:values].first[:invocations]
  end  
end