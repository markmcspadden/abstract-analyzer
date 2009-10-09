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