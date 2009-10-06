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

# I need at the data hash from the Payload
module FiverunsDashPayloadExtensions
  attr_reader :data
end
Fiveruns::Dash::Payload.__send__ :include, FiverunsDashPayloadExtensions

module Fiveruns::Dash::Store::Mongo
  # SET IN update.rb
  # On config start set :url param to some kind of mongo url

  def store_mongo(*uris)    
    Fiveruns::Dash.logger.info "Attempting to send #{payload.class}"
  
    # NOW BREAK IT DOWN
    # Each metric gets it's own doc
    # Use upsert (hopefully with incrementers)  
    if payload.is_a? Fiveruns::Dash::DataPayload
      data = payload.data

      data.each do |d|
        recipe_name = d[:recipe_name]
        name = d[:name]
        storage_name = "#{recipe_name}-#{name}"
        d[:created_at] = Time.now
        
        # TODO: Use upsert to handle cluser wide implementations
        DB.collection(storage_name).insert(d)
        Fiveruns::Dash.logger.info "Sent #{payload.class} to #{DB}"
      end
    else
      raise "Payload of type #{payload.class} Not Currently Supported"
    end
  rescue
    puts "ERROR IN STORE_MONGO: #{$!}"
    Fiveruns::Dash.logger.warn "Could not send #{payload.class}: #{$!}"
  end
end

module FiverunsDashUpdateExtensions
  include Fiveruns::Dash::Store::Mongo
    
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
           


      Fiveruns::Dash.configure do |config|        
        # config.add_recipe :actionpack, :url => 'http://example.org'
        @recipes.each do |r|
          config.add_recipe r[:name], r[:url]
        end
      end

      Fiveruns::Dash.session.interval = interval
      Fiveruns::Dash.session.start
    end
  end
end  