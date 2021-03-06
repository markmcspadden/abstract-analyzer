require 'fiveruns-dash-rails'

module AbstractAnalyzer
  module Middleware
    module Rails
      module Dash  
        # This is where we grab the analytics
        class Analyzer < DashAnalyzer::Base
          # Fiveruns::Dash.register_recipe :actionpack, :url => 'http://example.org' do |recipe|
          #   Fiveruns::Dash.logger.info 'REGISTERING ACTIONPACK RECIPE'
          #       
          #   recipe.time :response_time, :method => 'AbstractController::Base#process_action', :mark => true
          # end
    
          def initialize(*)
            # Fiveruns::Dash::Rails.load_recipes
            
            #@recipes = [{:name => :actionpack, :url => 'http://example.org'}]
            @recipes = [{:name => :ruby, :url => 'http://dash.fiveruns.com'},
                        {:name => :rails, :url => 'http://dash.fiveruns.com'}]
            super
          end
        end
  
        # This is where we view them
        class View < DashAnalyzer::TimeView
           def initialize(*)
             super
             #self.collection = 'actionpack-response_time'
           end
        end
      end
    end
  end
end