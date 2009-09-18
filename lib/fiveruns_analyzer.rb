require 'yaml'

require 'logger'

RAILS_DEFAULT_LOGGER = Logger.new(File.dirname(__FILE__) << "/fiveruns_logger.log")

require 'rubygems' # I know I know...

gem 'fiveruns-dash-ruby' # Put its path first
require 'fiveruns/dash'

module Fiveruns::Dash::Store
  module HTTP
    def store_http(*)
      # Confused that only INFO data is being stored
      Fiveruns::Dash.logger.info "Store http"
      Fiveruns::Dash.logger.info payload
    end    
  end
  module File
    def store_file(*)
      Fiveruns::Dash.logger.info "Store file"
      Fiveruns::Dash.logger.info payload
    end
  end
end

module FiverunsAnalyzer  
  class Logger   
    def initialize(app)
      startup_fiveruns
      
      @app = app
    end
 
    def call(env)
      RAILS_DEFAULT_LOGGER.info "CALLING"      
      @app.call(env)
    end
    
    def startup_fiveruns
      Fiveruns::Dash.register_recipe :actionpack, :url => 'http://example.org' do |recipe|
        Fiveruns::Dash.logger.info 'REGISTERING'
        recipe.time :response_time, :method => 'FiverunsAnalyzer::Logger#call', :mark => true
      end

      Fiveruns::Dash.configure do |config|
        require "actionpack"
        config.add_recipe :actionpack, :url => 'http://example.org'
      end

      Fiveruns::Dash.session.start
    end
  end
end  