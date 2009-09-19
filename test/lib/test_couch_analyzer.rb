require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class CouchRestTest < Test::Unit::TestCase
  include Rack::Test::Methods

  class HelloApp < HelloWorld
    
  end

  class MyApp < CouchRest::Logger

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
    
    puts CouchRest::Logger.log
    
    CouchRest::Logger.log.sort_by{ |l| l["started_at"] }.each do |l|
      puts "#{l["url"]} - #{l["started_at"]} - #{l["ended_at"]} - #{l["duration"]}"
    end
    
    assert_equal 5, CouchRest::Logger.log.size
  end
end