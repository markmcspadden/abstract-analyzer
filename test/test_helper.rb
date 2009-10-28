require "rubygems" # I know...I know...don't do this

require "test/unit"
require "autotest"

require "rack/test"

require File.dirname(__FILE__) << "/../lib/abstract_analyzer"

# Create a test mongo db
test_mongo_db = Mongo::Connection.new('localhost', 27017).db('test-dash-analyzer-db')
AbstractAnalyzer.const_set("DB", test_mongo_db)

# Create a test log
test_logger = Logger.new(File.dirname(__FILE__) << "/abstract_analyzer_logger.log")
AbstractAnalyzer.const_set("LOGGER", test_logger)

# Create a test rack app
class FooApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
  end
end