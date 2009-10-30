require File.dirname(__FILE__) << '/view'
require File.dirname(__FILE__) << '/dash_analyzer'
require File.dirname(__FILE__) << '/middleware'

module AbstractAnalyzer
  
  @@STORE = nil
  @@DB = nil
  @@LOGGER = nil
  
  class << self
    
    def db
      @@DB
    end
    def db=(connection)
      @@DB = connection
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
    
  end
  
end



