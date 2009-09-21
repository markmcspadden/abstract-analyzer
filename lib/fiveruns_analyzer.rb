require 'yaml'

require 'logger'

RAILS_DEFAULT_LOGGER = Logger.new(File.dirname(__FILE__) << "/fiveruns_logger.log")

require 'rubygems' # I know I know...

gem 'fiveruns-dash-ruby' # Put its path first
require 'fiveruns/dash'

require 'mongo'  

DB = Mongo::Connection.new('localhost', 27017).db('fiveruns-analyzer-db')      

# class Fiveruns::Dash::Configuration
#   attr_accessor :db
# end

module Fiveruns::Dash::Store
  module HTTP
    def store_http(*)
      # Confused that only INFO data is being stored
      Fiveruns::Dash.logger.info "Store http"
      Fiveruns::Dash.logger.info payload
            
      # puts payload
      # puts "---------"
      # 
      # coll = DB.collection('payloads')
      # coll.insert({'raw' => payload.to_fjson})
      # 
      # puts "There are #{coll.count()} records. Here they are:"
      # coll.find().each { |doc| puts doc.inspect }
      
      # Do we really need ANOTHER thread?
      # This process is already threaded (right?)
      Thread.new(DB, payload) do |db, payload| 
        db.collection('payloads').insert({'raw' => payload.to_fjson})
      end
    rescue
      puts "ERROR IN STORE_HTTP: #{$!}"
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
    attr_accessor :db
       
    def initialize(app)
      @db = DB
      
      startup_fiveruns
      
      @app = app
    end
 
    def call(env)
      RAILS_DEFAULT_LOGGER.info "CALLING" 
      
      # NOTE: I really don't understand Fiveruns::Dash:Context
      # This is never true right now, always falls to else
      trace_context = ["actionpack", "FiverunsAnalyzer:Logger#call"]
      if Fiveruns::Dash.trace_contexts.include?(trace_context)
        Fiveruns::Dash.session.trace(trace_context) do
          @app.call(env)
        end
      else
        # ALWAYS HERE RIGHT NOW
        @app.call(env)
      end        
    end
    
    def startup_fiveruns      
      Fiveruns::Dash.register_recipe :actionpack, :url => 'http://example.org' do |recipe|
        Fiveruns::Dash.logger.info 'REGISTERING ACTIONPACK RECIPE'
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