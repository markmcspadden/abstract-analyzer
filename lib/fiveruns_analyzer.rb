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

module Fiveruns::Dash
  class Session
    def interval=(value)
      reporter.interval = value
    end
  end      
end

module Fiveruns::Dash::Store  
  # SET IN update.rb
  # On config start set :url param to some kind of mongo url
  module Mongo
    def store_mongo(*uris)
      puts "URIS: #{uris}"
      
      Fiveruns::Dash.logger.info "Attempting to send #{payload.class}"
        # if (uri = uris.detect { |u| transmit_to(add_path_to(u)) })
        #   Fiveruns::Dash.logger.info "Sent #{payload.class} to #{uri}"
        #   uri
        # else
        #   Fiveruns::Dash.logger.warn "Could not send #{payload.class}"
        # end
      
      puts payload.class
      
      puts payload.to_fjson
      puts payload.params
      # extra_params = extra_params_for(payload)
      # multipart = Multipart.new(payload.io, payload.params.merge(extra_params))
      
      # GET JSON IN THERE FIRST
      # Confused that only INFO data is being stored
      Fiveruns::Dash.logger.info payload

      puts "PAYLOAD IO"
      
      puts payload.io.to_s
      
      puts "PAYLOAD DATA"
      y payload

      # puts payload
      # puts "---------"
      # 
      # coll = DB.collection('payloads')
      # coll.insert({'raw' => payload.to_fjson})
      # 
      # puts "There are #{coll.count()} records. Here they are:"
      # coll.find().each { |doc| puts doc.inspect }
      DB.collection('payloads').insert({'raw' => payload.to_fjson})


      
      # NOW BREAK IT DOWN
      # Each metric gets it's own doc
      # Use upsert (hopefully with incrementers)
      # 
      
      # Mongo db post on real time analytics
    rescue
      puts "ERROR IN STORE_MONGO: #{$!}"
      Fiveruns::Dash.logger.warn "Could not send #{payload.class}"
    end
  end
  
end

module Fiveruns::Dash
  class Update
    include Store::Mongo
    
    private

    def storage_method_for_with_mongo(scheme)
      if scheme =~ /^mongo/ 
        :mongo
      else
        storage_method_for_without_mongo(scheme)
      end
    end
    # alias_method_chain :storage_method_for, :mongo
    alias_method :storage_method_for_without_mongo, :storage_method_for
    alias_method :storage_method_for, :storage_method_for_with_mongo

    # Don't think I need to overwrite this
    # def safe_parse_with_mongo(url)
    #   puts url
    #   
    #   if url =~ /^mongo/
    #     url
    #   else
    #     url.respond_to?(:scheme) ? url : URI.parse(url)
    #   end
    # end
    # # alias_method_chain :safe_parse, :mongo
    # alias_method :safe_parse_without_mongo, :safe_parse
    # alias_method :safe_parse, :safe_parse_with_mongo
    
  end
end



module FiverunsAnalyzer  
  class Logger
    attr_accessor :db
       
    def initialize(app, dash_interval=60)
      @db = DB
      
      startup_dash(dash_interval)
      
      @app = app
    end
 
    def call(env)
      RAILS_DEFAULT_LOGGER.info "CALLING" 
      
      # NOTE: I really don't understand Fiveruns::Dash:Context
      # This is never true right now, always falls to else


      # DO NOT NEED THIS
      # trace_context = ["actionpack", "FiverunsAnalyzer:Logger#call"]
      # if Fiveruns::Dash.trace_contexts.include?(trace_context)
      #   Fiveruns::Dash.session.trace(trace_context) do
      #     @app.call(env)
      #   end
      # else
      #   # ALWAYS HERE RIGHT NOW
      #   @app.call(env)
      # end 
      @app.call(env)       
    end
    
    def startup_dash(interval = 60)
      Fiveruns::Dash.session.reset
      
      ENV['DASH_UPDATE'] = "mongo://db"
           
      Fiveruns::Dash.register_recipe :actionpack, :url => 'http://example.org' do |recipe|
        Fiveruns::Dash.logger.info 'REGISTERING ACTIONPACK RECIPE'
        recipe.time :response_time, :method => 'FiverunsAnalyzer::Logger#call', :mark => true
      end

      Fiveruns::Dash.configure do |config|        
        require "actionpack"
        config.add_recipe :actionpack, :url => 'http://example.org'
      end

      Fiveruns::Dash.session.interval = interval
      Fiveruns::Dash.session.start(true)
    end
  end
end  