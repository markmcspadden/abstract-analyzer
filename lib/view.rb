require 'usher'
require 'ruport'

DB = Mongo::Connection.new('localhost', 27017).db('fiveruns-analyzer-db')      

module AbstractAnalyzer
  class Base
    def db
      DB
    end

    def initialize(app)    
      @app = app
    end

    def call(env)
      method_name = "[#{env["REQUEST_METHOD"].to_s.downcase}] #{env["PATH_INFO"]}"

      # This has got to be not good for performance
      # Consider using the PATH_INFO var instead      
      if self.respond_to?(method_name)
        content = self.__send__(method_name)
        [200, {"Content-Type" => "text/plain"}, content]
      else
        # This is from Rails metal...but can't get it to work
        # [status, headers, response_body]
        # BUT THIS IS NOT RIGHT
        super
      end
    end
    
    class << self
      # From Railsnatra
      # Set @_routes on child classes
      def inherited(klass)
        klass.class_eval { @_routes = [] }
      end
      
      def to_app
        routes, controller = @_routes, self

        # From Railsnatra ;)
        # We're using Usher as a router for this project. To
        # simplify things, we just used the rack interface to
        # router and it's DSL.
        app = Usher::Interface.for(:rack) do
          routes.each do |route|
            conditions = {:request_method => route[:method]}
            add(route[:uri], :conditions => conditions.merge(route[:options])).
              to(controller.action(route[:action]))
          end
        end

        app
      end
      
      def get(uri, options = {}, &block)
        route(:get,  uri, options, &block)
      end
      
      private
      # From Railsnatra
      def route(http_method, uri, options, &block)
        # Since we need unique actions for each possible GET,
        # POST, etc... URLs, we add the method in the action
        # name. ActionController::Metal has the ability to
        # route an action with any name format.
        action_name = "[#{http_method}] #{uri}"
        # We save the route options in the global @_routes
        # variable so that we can build the routes when the
        # app is generated.
        @_routes << {:method => http_method.to_s.upcase, :uri => uri,
                     :action => action_name, :options => options}
        # Now, we finally create the action method.
        define_method(action_name, &block)
      end 
    end
  end # Base
  
  class TimeView < Base
    # Create some kind of index view
    get "/index" do
      coll = db.collection('actionpack-response_time')
      
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