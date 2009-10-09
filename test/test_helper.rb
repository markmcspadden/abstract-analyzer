require "rubygems" # I know...I know...don't do this

require "test/unit"
require "autotest"

require "rack/test"

require File.dirname(__FILE__) << "/../abstract_analyzer"

class FooApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
  end
end