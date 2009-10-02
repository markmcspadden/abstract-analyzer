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
    coll = app.db.collection('actionpack-response_time')
    coll.clear
    
    5.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval

    #coll.find().each { |row| puts row.class; puts row.inspect; puts "-------" }
    
    total_invocations = 0
    
    coll.find().each do |row|
      values = row[:values]
      if values
        invocations = values[:invocations]
        total_invocations += invocations
      end
    end

    assert 5, total_invocations
  end
  
  def test_mongo_data_store_with_multiple_metrics
    coll1 = app.db.collection('actionpack-response_time')
    coll1.clear
    
    coll2 = app.db.collection('actionpack-another_response_time')
    coll2.clear
    
    10.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval

    #coll.find().each { |row| puts row.class; puts row.inspect; puts "-------" }
    
    total_coll1_invocations = 0
    
    coll1.find().each do |row|
      values = row[:values]
      if values
        invocations = values[:invocations]
        total_coll1_invocations += invocations
      end
    end
    
    total_coll2_invocations = 0
    
    coll2.find().each do |row|
      values = row[:values]
      if values
        invocations = values[:invocations]
        total_coll2_invocations += invocations
      end
    end

    assert 5, total_coll1_invocations
    assert 5, total_coll2_invocations
  end
    
end