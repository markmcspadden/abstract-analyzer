# I think I will need this eventually...

# class Fiveruns::Dash::Configuration
#   attr_accessor :db
# end

# Allow the Fiveruns::Dash::Session interval to be set
module FiverunsDashSessionExtensions
  def interval=(value)
    reporter.interval = value
  end  
end
Fiveruns::Dash::Session.__send__ :include, FiverunsDashSessionExtensions


# Allow direct access to the Fiveruns::Dash::Payload data hash
module FiverunsDashPayloadExtensions
  attr_reader :data
end
Fiveruns::Dash::Payload.__send__ :include, FiverunsDashPayloadExtensions

# Setup a store_mongo method on Fiveruns::Dash::Store
# NOTE: I think there is a better way to do this
module FiverunsDashStoreMongo
  def store_mongo(*uris)    
    Fiveruns::Dash.logger.info "Attempting to send #{payload.class}"
  
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
    Fiveruns::Dash.logger.warn "Could not send #{payload.class}: #{$!}"
  end
end
Fiveruns::Dash::Store.__send__ :extend, FiverunsDashStoreMongo

# Allow Fiveruns::Dash::Update to recognize mongo style urls
# Yes I think I totally just made up mongo style urls
# They look like 'mongo://ANYTHING_GOES_HERE_FOR_NOW'

# Also, I think I like the duck punching better than this send/include/send/alias_method mess
# Open to rewrites
module FiverunsDashUpdateExtensions
  include FiverunsDashStoreMongo
    
  private
  def storage_method_for_with_mongo(scheme)
    if scheme =~ /^mongo/ 
      :mongo
    else
      storage_method_for_without_mongo(scheme)
    end
  end
end
Fiveruns::Dash::Update.__send__ :include, FiverunsDashUpdateExtensions
Fiveruns::Dash::Update.__send__ :alias_method, :storage_method_for_without_mongo, :storage_method_for
Fiveruns::Dash::Update.__send__ :alias_method, :storage_method_for, :storage_method_for_with_mongo

# Duck punched version
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