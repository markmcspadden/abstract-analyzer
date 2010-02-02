require 'ruport'

module DashAnalyzer
  
  class TimeView < AbstractAnalyzer::View
    
    def initialize(*)
      super
      setup_show
    end
    
    # Create some kind of index view
    get "/analytics" do      
      # Only look at time metrics for now
      collection_names =  if AbstractAnalyzer.store.to_s.downcase == "activerecord"
                            metrics.select{ |n| n.match(/time/) }
                          else
                            db.collection_names.select{ |n| n.match(/time/)}
                          end
      
      table = Table(:column_names => ["Metric", "Total Number of Calls", "Total Time (s)", "Avg Time per Call (s)"])
            
      puts collection_names
      puts collection_names.size
      
      AbstractAnalyzer.logger.warn collection_names
      AbstractAnalyzer.logger.warn collection_names.size
            
      collection_names.each do |name|        
        if AbstractAnalyzer.store.to_s.downcase == "activerecord"
          total_values = 0
          total_invocations = 0
        
          AbstractAnalyzer.logger.warn name
          AbstractAnalyzer.logger.warn AbstractAnalyzer.constants
        
          "AbstractAnalyzer::#{name.camelcase.singularize}".constantize.all.each do |row|
            AbstractAnalyzer.logger.warn row
            AbstractAnalyzer.logger.warn row.class
            AbstractAnalyzer.logger.warn row.attributes                        
            
            
            values = YAML::load row.values

            # Why is this an array
            if values && !values.empty?
              v = values.first
              value = v[:value]
              invocations = v[:invocations]

              total_values += value.to_f
              total_invocations += invocations.to_i
            end
          end
        else
          coll = db.collection(name)              
        
          total_values = 0
          total_invocations = 0
        
          coll.find().each do |row|
            values = row["values"]

            # Why is this an array
            if values && !values.empty?
              v = values.first
              value = v["value"]
              invocations = v["invocations"]

              total_values += value.to_f
              total_invocations += invocations.to_i
            end
          end
        end
        
        table << [name.to_s.titlecase, total_invocations.to_i, total_values.to_f, total_values.to_f/total_invocations.to_f]
      end
      
      trail = "There are more details at:\n#{collection_names.collect{ |n| " * /analytics/show/#{n}"}.join("\n")}"
      
      [table.to_s, trail].join("\n")
    end
    
    # Use the collection names to create views
    def setup_show
      collection_names =  if AbstractAnalyzer.store.to_s.downcase == "activerecord"
                            metrics.select{ |n| n.match(/time/) }
                          else
                            db.collection_names.select{ |n| n.match(/time/)}
                          end
      
      collection_names.each do |name|
        self.class.class_eval do
          get "/analytics/show/#{name}" do
            if AbstractAnalyzer.store.to_s.downcase == "activerecord"
              "AR SHOW"
            else
              coll = db.collection(name)

              lead = "Listing #{coll.count} #{name.to_s.titlecase} Rollups in the Last Hour"
    
              table = Table(:column_names => ["Time", "Metric Name", "Number of Calls", "Total Time"])

              total_invocations = 0
              total_values = 0.0

              # TODO: Reverse this collection
              # coll.find({:created_at => {:$gte => Time.now.advance(:hours => -1)}}, {:sort => {:created_at => Mongo::DESCENDING}}).each do |row|
              coll.find({:created_at => {:$gte => Time.now.advance(:hours => -1)}}, {:sort => ['created_at', 'descending']}).each do |row|
                values = row["values"]
        
                # Why is this an array
                if values && !values.empty?
                  value = values.first["value"]
                  invocations = values.first["invocations"]
          
                  total_values = value.to_f
                  total_invocations += invocations.to_i
                end
        
                table << [row["created_at"], row["description"], invocations.to_i, value.to_f]
              end
      
              results = []
              results << "Total Calls: #{total_invocations}"
              results << "Total Time: #{total_values} seconds"
              results << "Avg Time per Call: #{total_values/total_invocations.to_f} seconds"
              results = results.join("\n")

              [lead, results, table.to_s].join("\n")
            end
          end
        end
      end
    end
    

    
  end
end