require 'logger'

RAILS_DEFAULT_LOGGER = Logger.new(File.dirname(__FILE__) << "/fiveruns_logger.log")

require 'rubygems' # I know I know...

gem 'fiveruns-dash-ruby' # Put its path first
require 'fiveruns/dash'

module Fiveruns::Dash::Store
  module HTTP
    def store_http(*)
      Fiveruns::Dash.logger.info "Store http"
      Fiveruns::Dash.logger.info payload
    end
  end
end

module FiverunsAnalyzer  
  class Logger   
    def initialize(app)
      @app = app
    end
 
    def call(env)
      RAILS_DEFAULT_LOGGER.info "CALLING"
      @app.call(env)
    end
  end



  
  Fiveruns::Dash.register_recipe :actionpack, :url => 'http://example.org' do |recipe|
    Fiveruns::Dash.logger.warn 'REGISTERING'
    recipe.time :response_time, :method => 'Fiveruns::Logger#call', :mark => true

    # recipe.time :response_time, :method => 'ActionController::Base#perform_action', :mark => true
    # recipe.counter :requests, 'Requests', :incremented_by => 'ActionController::Base#perform_action'
    # 
    # targets = []
    # if defined?(ActionView::Renderable)
    #   targets << 'ActionView::Renderable#render'
    # else
    #   targets << 'ActionView::Template#render' if defined?(ActionView::Template)
    #   targets << 'ActionView::PartialTemplate#render' if defined?(ActionView::PartialTemplate)
    # end
    # if !targets.empty?
    #   recipe.time :render_time, :method => targets
    # else
    #   Fiveruns::Dash.logger.warn 'Collection of "render_time" unsupported for this version of Rails'
    # end

  end
  
  Fiveruns::Dash.configure do |config|
    require "actionpack"
    config.add_recipe :actionpack, :url => 'http://example.org'
  end
  
  Fiveruns::Dash.session.start   
end