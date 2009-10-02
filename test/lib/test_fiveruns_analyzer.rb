require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class FiverunsAnalyzer::LoggerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  class HelloApp < HelloWorld

  end

  class MyApp < FiverunsAnalyzer::Logger

  end
  
  def app
    MyApp.new(HelloApp.new, 1)
  end

  # MAKE SURE MONGO IS RUNNING ON localhost:27017
  def test_mongodb
    get "/foo"
    
    assert_not_nil app.db
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
    
    y data.first[:values]
    
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
    
    5.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval
    
    assert 1 <= coll.count
    
    
    # coll.find().each { |row| puts row.class; puts row.inspect; puts "-------" }
    
    total_invocations = 0
    
    coll.find().each do |row|
      raw = row[:raw]
      if raw
        values = raw[:values]
        if values
          invocations = values[:invocations]
          total_invocations += invocations
        end
      end
    end

    assert 5, total_invocations
  end
  
    
end