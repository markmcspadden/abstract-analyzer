module AbstractAnalyzer
  class View
    # def initialize(app)
    #   @app = app
    # end

    def call(env)
      [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
    end
    
    
  end
end