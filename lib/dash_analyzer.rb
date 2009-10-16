require 'yaml'

require 'logger'

require 'rubygems' # I know I know...


gem 'fiveruns-dash-ruby' # Put its path first
require 'fiveruns/dash'

# TODO: Only include the storage library needed
require 'mongo'  

gem 'activerecord', '=2.3.4'
require 'active_record'

require File.dirname(__FILE__) << '/dash_analyzer/dash_extensions'
require File.dirname(__FILE__) << '/dash_analyzer/base'
require File.dirname(__FILE__) << '/dash_analyzer/view'

module DashAnalyzer

end





