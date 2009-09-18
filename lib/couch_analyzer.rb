# Mostly a copy of http://merbist.com/2009/07/27/ruby-rack-and-couchdb-lots-of-awesomeness/
# Used for mostly for learning purposes

module CouchRest
  class Logger
    
    @@LOG = [] 
        
    def initialize(app)
      @app = app
    end
 
    def call(env)
      env['HTTP_HOST'] = env['SERVER_NAME']
      env['REQUEST_URI'] = env['PATH_INFO']
      
      log = {}
      log['started_at'] = Time.now
      log['env'] = env
      log['url'] = 'http://' + env['HTTP_HOST'] + env['REQUEST_URI'] 
      response = @app.call(env)
      log['ended_at'] = Time.now
      log['duration'] = log['ended_at'] - log['started_at']
      # let's report the log in a different thread so we don't slow down the app
      Thread.new(log){|log| @@LOG << log}# .inspect}
      response
    end
    
    class << self
      
      def log
        @@LOG
      end
      
    end
 
  end
end