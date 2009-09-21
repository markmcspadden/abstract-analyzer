require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class FiverunsAnalyzer::LoggerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  class HelloApp < HelloWorld

  end

  class MyApp < FiverunsAnalyzer::Logger

  end
  
  def app
    MyApp.new(HelloApp.new)
  end

  # MAKE SURE MONGO IS RUNNING ON localhost:27017
  def test_mongodb
    get "/foo"
    
    assert_not_nil app.db
    
    # coll = db.collection('test')
    # coll.clear
    # 3.times { |i| coll.insert({'a' => i+1}) }
    # puts "There are #{coll.count()} records. Here they are:"
    # coll.find().each { |doc| puts doc.inspect }
  end

  def test_success
    get "/foo"
    
    assert last_response.ok?
  end
  
  def test_session_data_store
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
  
  def test_mongo_data_store
    coll = app.db.collection('payloads')
    coll.clear
    
    sleep 10
    
    5.times do
      get "/foo"
    end
    
    # Trying to test threaded processes is a beast
    # Fiveruns threads it's storing, and thus the db storages is threaded
    # This 60 second sleep is about the right amount for the 5 requests
    sleep 60
    
    assert_equal 5, coll.count
  end
  
    
end