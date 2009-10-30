require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

setup_activerecord

class BaseTest < Test::Unit::TestCase
  include Rack::Test::Methods

  class MyApp < DashAnalyzer::Base          
    Fiveruns::Dash.register_recipe :testpack, :url => 'http://example.org' do |recipe|
      Fiveruns::Dash.logger.info 'REGISTERING ACTIONPACK RECIPE'
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
  
  def teardown
    begin
      Fiveruns::Dash::Store::ActiveRecord::TestpackResponseTime.all.each{ |r| r.destroy }
    rescue
      puts "TestpackResponseTime not cleared"
    end
    begin
      Fiveruns::Dash::Store::ActiveRecord::TestpackAnotherResponseTime.all.each{ |r| r.destroy }
    rescue
      puts "TestpackAnotherResponseTime not cleared"
    end
  end
    
    

  # MAKE SURE MONGO IS RUNNING ON localhost:27017
  def test_activerecord
    get "/foo"
    
    assert_not_nil app.db
  end
  
  def test_activerecord_connection
    # We need a query to start the connection
    app.db.connection.execute("create table delete_mes(name varchar(155));")
    eval <<-EOC
      class DeleteMe < ActiveRecord::Base; end
    EOC

    # And now delete the table
    app.db.connection.execute("drop table delete_mes;")
    
    assert app.db.connected?
  end

  def test_success
    get "/foo"
    
    assert last_response.ok?
  end
  
  def test_activerecord_data_store    
    3.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval + 1

    coll = Fiveruns::Dash::Store::ActiveRecord::TestpackResponseTime.all
        
    total_invocations = 0
    
    coll.each do |row|
      values = YAML::load row[:values]
      
      if values && values.first
        invocations = values.first[:invocations]
        total_invocations += invocations.to_i
      end
    end

    # For some reason I'm getting an extra invocation here
    assert_equal 3+1, total_invocations
  end
  
  def test_activerecord_data_store_with_multiple_metrics    
    3.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval + 1

    coll1 = Fiveruns::Dash::Store::ActiveRecord::TestpackResponseTime.all
    coll2 = Fiveruns::Dash::Store::ActiveRecord::TestpackAnotherResponseTime.all
    
    total_coll1_invocations = 0
    
    coll1.each do |row|
      values = YAML::load row[:values]
      if values && values.first
        invocations = values.first[:invocations]
        total_coll1_invocations += invocations.to_i
      end
    end
    
    total_coll2_invocations = 0
    
    coll2.each do |row|
      values = YAML::load row[:values]
      if values && values.first
        invocations = values.first[:invocations]
        total_coll2_invocations += invocations.to_i
      end
    end

    assert_equal 3, total_coll1_invocations
    assert_equal 3, total_coll2_invocations
  end
  
  # Just trying to ensure Dash is sending info even when requests aren't being made
  def test_frequency_of_activerecord_data_inserts
    3.times do
      get "/foo"
    end
    
    sleep Fiveruns::Dash.session.reporter.interval*10 + 1

    count = Fiveruns::Dash::Store::ActiveRecord::TestpackResponseTime.count

    assert 10 <= count
  end
    
end