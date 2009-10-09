require 'ruport'

module DashAnalyzer
  class TimeView < AbstractAnalyzer::View
    # Create some kind of index view
    get "/analytics" do
      coll = db.collection(@collection)

      lead = "Listing #{coll.count} Response Time Rollups"
    
      table = Table(:column_names => ["Time", "Metric Name", "Number of Calls", "Measurement"])

      total_invocations = 0
      total_values = 0.0

      coll.find().each do |row|
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

      [lead, table.to_s, results].join("\n")
    end
    
    # Just a dummy action to help with refactoring
    get "/show" do
      "Show me."
    end    
  end
end