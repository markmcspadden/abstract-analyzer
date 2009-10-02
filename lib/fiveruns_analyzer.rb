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

module FiverunsDashSessionExtensions
  def interval=(value)
    reporter.interval = value
  end  
end

Fiveruns::Dash::Session.__send__ :include, FiverunsDashSessionExtensions

# module Fiveruns::Dash
#   class Session
#     def interval=(value)
#       reporter.interval = value
#     end
#   end      
# end


module Fiveruns::Dash::Store::Mongo
  # SET IN update.rb
  # On config start set :url param to some kind of mongo url

  def store_mongo(*uris)
    puts "URIS: #{uris}"
    
    Fiveruns::Dash.logger.info "Attempting to send #{payload.class}"
    # if (uri = uris.detect { |u| transmit_to(add_path_to(u)) })
    #   Fiveruns::Dash.logger.info "Sent #{payload.class} to #{uri}"
    #   uri
    # else
    #   Fiveruns::Dash.logger.warn "Could not send #{payload.class}"
    # end
  
    # NOW BREAK IT DOWN
    # Each metric gets it's own doc
    # Use upsert (hopefully with incrementers)
    #
    # NOTE: What's the diff between an InfoPayload and a DataPayload
    if payload.class.to_s =~ /Fiveruns::Dash::(Data|Info)Payload/
      DB.collection('payloads').insert({'raw' => payload.to_fjson})
      Fiveruns::Dash.logger.info "Sent #{payload.class} to #{DB}"
    else
      raise "Payload Not Currently Supported"
    end
    
    # Mongo db post on real time analytics
  rescue
    puts "ERROR IN STORE_MONGO: #{$!}"
    Fiveruns::Dash.logger.warn "Could not send #{payload.class}"
  end
end

module FiverunsDashUpdateExtensions  
  private
  def storage_method_for_with_mongo(scheme)
    if scheme =~ /^mongo/ 
      :mongo
    else
      storage_method_for_without_mongo(scheme)
    end
  end
  # alias_method_chain :storage_method_for, :mongo
  # alias_method :storage_method_for_without_mongo, :storage_method_for
  # alias_method :storage_method_for, :storage_method_for_with_mongo
end

# I think I like the duck punching better than this :/
# Open to rewrites
Fiveruns::Dash::Update.__send__ :include, Fiveruns::Dash::Store::Mongo
Fiveruns::Dash::Update.__send__ :include, FiverunsDashUpdateExtensions
Fiveruns::Dash::Update.__send__ :alias_method, :storage_method_for_without_mongo, :storage_method_for
Fiveruns::Dash::Update.__send__ :alias_method, :storage_method_for, :storage_method_for_with_mongo

# module Fiveruns::Dash
#   class Update
#     include Store::Mongo
#     
#     private
# 
#     def storage_method_for_with_mongo(scheme)
#       if scheme =~ /^mongo/ 
#         :mongo
#       else
#         storage_method_for_without_mongo(scheme)
#       end
#     end
#     # alias_method_chain :storage_method_for, :mongo
#     alias_method :storage_method_for_without_mongo, :storage_method_for
#     alias_method :storage_method_for, :storage_method_for_with_mongo    
#   end
# end



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