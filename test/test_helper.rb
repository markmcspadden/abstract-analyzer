require "rubygems" # I know...I know...don't do this

require "test/unit"
require "autotest"

require "rack/test"

require File.dirname(__FILE__) << "/../lib/abstract_analyzer"

# Create a test log
test_logger = Logger.new(File.dirname(__FILE__) << "/abstract_analyzer_logger.log")
AbstractAnalyzer.logger = test_logger

# Different DB options
# Set in each test file
def setup_mongodb
  # Create a test mongo db for defaults
  test_mongo_db = Mongo::Connection.new('localhost', 27017).db('test-dash-analyzer-db')
  
  AbstractAnalyzer.db = test_mongo_db
  AbstractAnalyzer.store = "mongoDB"
end

require 'sqlite3'
def setup_activerecord  
  # Setup sqlite3 db to test ActiveRecord
  db = SQLite3::Database.new('test-dash-analyzer.db') unless File.exists?('test-dash-analyzer.db') 
  connection = ActiveRecord::Base.establish_connection(
                  :adapter  => 'sqlite3',
                  :database => 'test-dash-analyzer.db'
                )
  
  AbstractAnalyzer.db = connection
  AbstractAnalyzer.store = "ActiveRecord"
end

# Create a test rack app
class FooApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
  end
end