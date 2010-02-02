# Setup db to receive rollups
class Fiveruns::Dash::Configuration
  attr_accessor :db
end

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
module Fiveruns::Dash::Store::Mongo
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
        Fiveruns::Dash.session.configuration.db.collection(storage_name).insert(d)
        Fiveruns::Dash.logger.info "Sent #{payload.class} to #{Fiveruns::Dash.session.configuration.db}"
      end
    else
      raise "Payload of type #{payload.class} Not Currently Supported"
    end
  rescue
    Fiveruns::Dash.logger.warn "Could not send #{payload.class}: #{$!}"
  end
end

# Setup a store_activerecord method on Fiveruns::Dash::Store
# NOTE: This + the mongo store need to be done better
module Fiveruns::Dash::Store::ActiveRecord
  include AbstractAnalyzer
  
  def store_activerecord(*uris)    
    Fiveruns::Dash.logger.info "Attempting to send #{payload.class}"
  
    if payload.is_a? Fiveruns::Dash::DataPayload
      data = payload.data

      data.each do |d|
        recipe_name = d[:recipe_name]
        name = d[:name]
        storage_name = "#{recipe_name}-#{name}"
        d[:created_at] = Time.now
        
        activerecord_insert(storage_name, d)
        
        Fiveruns::Dash.logger.info "Sent #{payload.class} to #{Fiveruns::Dash.session.configuration.db}"
      end
    else
      raise "Payload of type #{payload.class} Not Currently Supported"
    end
  rescue
    Fiveruns::Dash.logger.warn "Could not send #{payload.class}: #{$!}"
  end
  
  def activerecord_insert(storage_name, data)        
    begin
      class_name = storage_name.gsub("-", "_").camelcase
      
      # Create our ActiveRecord class
      if !(defined?(class_name.constantize) == "constant")
        Fiveruns::Dash.logger.warn "Attempting to create a model for: #{storage_name}"
        
        AbstractAnalyzer.module_eval <<-EOC
          class #{class_name} < ActiveRecord::Base; end
        EOC
      else
        Fiveruns::Dash.logger.warn "Model defined for: #{storage_name} and defined as: #{defined?(class_name.constantize)}"
      end
      
      # Create our db table if it doesn't exist
      table_name = class_name.underscore.pluralize
      unless ActiveRecord::Base.connection.tables.include?(table_name) 
        begin   
          Fiveruns::Dash.logger.warn "Attempting to create a table for this metric: #{storage_name}"
      
          # TODO: Find a better way to do this
          db_columns = []
          Fiveruns::Dash.logger.warn "------------------"
          data.each_pair do |k,v|          
            Fiveruns::Dash.logger.warn [k, v.class.to_s.downcase]
            
            # Get the correct column types
            column_type = case v.class.to_s
                            when "Array": "string"
                            when "Symbol": "string"
                            when "NilClass": "string"
                            when "Time": "datetime"
                            else v.class.to_s.downcase
                          end
                          
            # Marshal the data for arrays
            case v.class.to_s
              when "Array"
                Fiveruns::Dash.logger.warn "ARRAY"
                Fiveruns::Dash.logger.warn v
                Fiveruns::Dash.logger.warn Marshal.dump(v)
                Fiveruns::Dash.logger.warn Marshal.dump(v).class.to_s
                Fiveruns::Dash.logger.warn v.to_yaml
                Fiveruns::Dash.logger.warn v.to_yaml.class.to_s
                
                data[k] = v.to_yaml
              when "Symbol"
                data[k] = v.to_s
            
            end
                          
            db_columns << [k, column_type]
          end
            
          eval <<-EOC
            class Create#{class_name} < ActiveRecord::Migration
              def self.up
                create_table :#{table_name} do |t|
                  #{db_columns.collect{ |dbc| "t.#{dbc[1]} :#{dbc[0]}"}.join(";")}
                end
              end

              def self.down
                drop_table :#{class_name.pluralize}
              end
            end
      
            Create#{class_name}.up
          EOC
        rescue
          Fiveruns::Dash.logger.warn "Could not create a table for this metric: #{storage_name}. Reason: #{$!}"
        end
      end
      

      # Push the record to the db
      Fiveruns::Dash.logger.warn "Attempting insert this metric into a model: #{storage_name}"      
      "AbstractAnalyzer::#{class_name}".constantize.create(data)
    rescue
      Fiveruns::Dash.logger.warn "Could not send this metric: #{storage_name}. Reason: #{$!}"
    end
  end
end

# Allow Fiveruns::Dash::Update to recognize mongo style urls
# Yes I think I totally just made up mongo style urls
# They look like 'mongo://ANYTHING_GOES_HERE_FOR_NOW'

# Same for activerecord urls

# Also, I think I like the duck punching better than this send/include/send/alias_method mess
# Open to rewrites
module FiverunsDashUpdateExtensions
  include Fiveruns::Dash::Store::Mongo
  include Fiveruns::Dash::Store::ActiveRecord
    
  private
  def storage_method_for_with_db(scheme)
    if scheme =~ /^mongo/ 
      :mongo
    elsif scheme =~ /^activerecord/
      :activerecord
    else
      storage_method_for_without_db(scheme)
    end
  end
end
Fiveruns::Dash::Update.__send__ :include, FiverunsDashUpdateExtensions
Fiveruns::Dash::Update.__send__ :alias_method, :storage_method_for_without_db, :storage_method_for
Fiveruns::Dash::Update.__send__ :alias_method, :storage_method_for, :storage_method_for_with_db

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