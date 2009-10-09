require File.dirname(__FILE__) << '/rails/dash'

module AbstractAnalyzer
  module Middleware
    # Implementation
    # In RAILS_ROOT/config/initializers/middlewares.rb
    #
    #   require 'abstract_analyzer/abstract_analyzer'
    #
    #   # Setup the Analyzer DB
    #   abstract_analyzer_db = Mongo::Connection.new('localhost', 27017).db('aa-rails-dash-analyzer-db')
    #   AbstractAnalyzer.const_set("DB", abstract_analyzer_db)
    # 
    #   # Setup the Analyzer LOGGER
    #   abstract_logger = Logger.new("#{RAILS_ROOT}/log/abstract_analyzer_logger.log")
    #   AbstractAnalyzer.const_set("LOGGER", abstract_logger)
    # 
    #   # Use the Analyzer and View middlewares
    #   ActionController::Dispatcher.middleware.use AbstractAnalyzer::Middleware::Rails::Dash::Analyzer
    #   ActionController::Dispatcher.middleware.use AbstractAnalyzer::Middleware::Rails::Dash::View
    #
    # NOTE: The require piece will be replace by an environment.rb config.gem call at some point
    module Rails
    end
  end
end