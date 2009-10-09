require "rubygems" # I know...I know...don't do this

require "test/unit"
require "autotest"

require "rack/test"

require File.dirname(__FILE__) << "/../abstract_analyzer"

# Create a test mongo db
mongo_db = Mongo::Connection.new('localhost', 27017).db('test-dash-analyzer-db')
AbstractAnalyzer.const_set("DB", mongo_db)

# Create a test rack app
class FooApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
  end
end