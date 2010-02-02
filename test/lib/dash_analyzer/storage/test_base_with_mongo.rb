require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class BaseTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
#  def setup
    setup_mongodb
#  end

  class MyApp < DashAnalyzer::Base        
    Fiveruns::Dash.register_recipe :testpack, :url => 'http://example.org' do |recipe|
      Fiveruns::Dash.logger.info 'REGISTERING TESTPACK RECIPE'
      recipe.time :response_time, :method => 'DashAnalyzer::Base#call', :mark => true
      recipe.time :another_response_time, :method => 'DashAnalyzer::Base#call', :mark => true
    end
    
    def initialize(*)
      @recipes = [{:name => :testpack, :url => 'http://example.org'}]
      super
    end  
  end
  
  def app
    MyApp.new(FooApp.new, 1)
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
  
  def test_mongo_data_store
    coll = app.db.collection('testpack-response_time')
    coll.remove
    
    5.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval + 1
    
    total_invocations = 0
    
    coll.find().each do |row|
      values = row["values"]
      if values && values.first
        invocations = values.first["invocations"]
        total_invocations += invocations
      end
    end

    assert_equal 5, total_invocations
  end
  
  def test_mongo_data_store_with_multiple_metrics
    coll1 = app.db.collection('testpack-response_time')
    coll1.remove
    
    coll2 = app.db.collection('testpack-another_response_time')
    coll2.remove
    
    3.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval + 1
    
    total_coll1_invocations = 0
    
    coll1.find().each do |row|
      values = row["values"]
      if values && values.first
        invocations = values.first["invocations"]
        total_coll1_invocations += invocations
      end
    end
    
    total_coll2_invocations = 0
    
    coll2.find().each do |row|
      values = row["values"]
      if values && values.first
        invocations = values.first["invocations"]
        total_coll2_invocations += invocations
      end
    end

    assert_equal 3, total_coll1_invocations
    assert_equal 3, total_coll2_invocations
  end
  
  # Just trying to ensure Dash is sending info when requests aren't being made
  def test_frequency_of_mongo_data_inserts
    coll = app.db.collection('testpack-response_time')
    coll.remove
    
    5.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval*20

    assert 20 <= coll.count
  end
    
end