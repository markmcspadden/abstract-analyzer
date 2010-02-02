require File.dirname(__FILE__) << '/view'
require File.dirname(__FILE__) << '/dash_analyzer'
require File.dirname(__FILE__) << '/middleware'

module AbstractAnalyzer
  
  @@STORE = nil
  @@DB = nil
  @@LOGGER = nil
  @@METRICS = []
  
  class << self
    
    def db
      @@DB
    end
    def db=(connection)
      @@DB = connection
      
      if store.to_s.downcase == "activerecord"
        @@METRICS = connection.tables
      else
        @@METRICS = []
      end
      
      @@DB
    end
    
    def store
      @@STORE
    end
    def store=(store_type)
      @@STORE = store_type
    end
    
    def logger
      @@LOGGER
    end
    def logger=(log)
      @@LOGGER = log
    end
    
    def metrics
      @@METRICS
    end
    def metrics=(value)
      @@METRICS = value
    end
    
  end
  
end



