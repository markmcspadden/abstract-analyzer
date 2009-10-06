module AbstractAnalyzer
  class View
    # def initialize(app)
    #   @app = app
    # end

    def call(env)
      # TODO: What happens if the method isn't found???
      content = self.__send__ "[#{env["REQUEST_METHOD"].to_s.downcase}] #{env["PATH_INFO"]}"
      [200, {"Content-Type" => "text/plain"}, content]
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
    
    
  end
end