require "rubygems" # I know...I know...don't do this

require "test/unit"
require "autotest"

require "rack/test"

require File.dirname(__FILE__) << "/../lib/abstract_analyzer"

# Create a test log
test_logger = Logger.new(File.dirname(__FILE__) << "/abstract_analyzer_logger.log")
AbstractAnalyzer.const_set("LOGGER", test_logger)

# Setup different DB options
# Important, these need to be set at a file level
# Because we're using module level constants, once they are set, they tend to stick
def setup_mongodb
  clear_abstract_analyzer_constants

  # Create a test mongo db for defaults
  AbstractAnalyzer.const_set("STORE", "mongoDB")
  test_mongo_db = Mongo::Connection.new('localhost', 27017).db('test-dash-analyzer-db')
  AbstractAnalyzer.const_set("DB", test_mongo_db)
end

def setup_activerecord
  clear_abstract_analyzer_constants
  
  # Setup sqlite3 db to test ActiveRecord
  require 'sqlite3'
  db = SQLite3::Database.new('test-dash-analyzer.db')
  connection = ActiveRecord::Base.establish_connection(
                  :adapter  => 'sqlite3',
                  :database => 'test-dash-analyzer.db'
                )
  AbstractAnalyzer.const_set("DB", connection)
  AbstractAnalyzer.const_set("STORE", "ActiveRecord")
end

def clear_abstract_analyzer_constants  
  AbstractAnalyzer.__send__(:remove_const, :DB) if AbstractAnalyzer.const_defined?("DB")
  AbstractAnalyzer.__send__(:remove_const, :STORE) if AbstractAnalyzer.const_defined?("STORE")
  
  puts "----"
  puts AbstractAnalyzer.const_defined?("DB")
  puts AbstractAnalyzer.const_defined?("STORE")
end

# Create a test rack app
class FooApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
  end
end