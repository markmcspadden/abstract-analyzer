module DashAnalyzer
  # Hooks up dash to your db
  # Implement in as a middleware like so:
  #
  # class MyApp < DashAnalyzer::Base 
  #   Fiveruns::Dash.register_recipe :testpack, :url => 'http://example.org' do |recipe|
  #     Fiveruns::Dash.logger.info 'REGISTERING ACTIONPACK RECIPE'
  #     recipe.time :response_time, :method => 'DashAnalyzer::Base#call', :mark => true
  #     recipe.time :another_response_time, :method => 'DashAnalyzer::Base#call', :mark => true
  #   end
  #   
  #   def initialize(*)
  #     @recipes = [{:name => :testpack, :url => 'http://example.org'}]
  #     super
  #   end 
  # end
  #  
  class Base    
    attr_accessor :db, :logger, :recipes
       
    def initialize(app, dash_interval=60)            
      @db = AbstractAnalyzer.db
      @logger = AbstractAnalyzer.logger
      
      startup_dash(dash_interval)
      
      @app = app
    end
 
    def call(env)       
      @app.call(env)       
    end
    
    def startup_dash(interval = 60)
      return if Fiveruns::Dash.session.reporter.started?
      
      Fiveruns::Dash.session.reset
      
      Fiveruns::Dash.logger = @logger
      
      ENV['DASH_UPDATE'] =  case AbstractAnalyzer.store.to_s.downcase
                              when "activerecord": "activerecord://db"
                              when "mongodb": "mongo://db"
                              else "mongo://db"
                            end
           
      Fiveruns::Dash.configure do |config|
        config.db = db
                
        @recipes.each do |r|
          config.add_recipe r[:name], r[:url]
        end
      end

      Fiveruns::Dash.session.interval = interval
      Fiveruns::Dash.session.start
    end
  end
end