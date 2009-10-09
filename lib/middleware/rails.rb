require File.dirname(__FILE__) << '/rails/dash'

module AbstractAnalyzer
  module Middleware
    # Implementation
    # In RAILS_ROOT/config/initializers/middlewares.rb
    #
    #   require 'abstract_analyzer/abstract_analyzer'
    #   ActionController::Dispatcher.middleware.use AbstractAnalyzer::Middleware::Rails::Dash::Analyzer
    #   ActionController::Dispatcher.middleware.use AbstractAnalyzer::Middleware::Rails::Dash::View
    #
    # NOTE: The require piece will be replace by an environment.rb config.gem call at some point
    module Rails
    end
  end
end