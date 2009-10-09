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
    attr_accessor :db
       
    def initialize(app, dash_interval=60)      
      @db = AbstractAnalyzer.const_get("DB")
      
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