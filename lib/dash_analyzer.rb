require 'yaml'

require 'logger'

require 'rubygems' # I know I know...

gem 'fiveruns-dash-ruby' # Put its path first
require 'fiveruns/dash'

require 'mongo'  

require 'dash_analyzer/dash_extensions'
require 'dash_analyzer/base'
require 'dash_analyzer/view'

module DashAnalyzer

  DB = Mongo::Connection.new('localhost', 27017).db('fiveruns-analyzer-db')      
  RAILS_DEFAULT_LOGGER = Logger.new(File.dirname(__FILE__) << "/fiveruns_logger.log")

end





