require File.dirname(__FILE__) << '/lib/view'
require File.dirname(__FILE__) << '/lib/dash_analyzer'
require File.dirname(__FILE__) << '/lib/middleware'

module AbstractAnalyzer
  
  # CONSTANTS DB, LOGGER are currently being set and expected
  
  # DB = Mongo::Connection.new('localhost', 27017).db('abstract-analyzer-db')      
  # LOGGER = Logger.new(File.dirname(__FILE__) << "/abstract_analyzer_logger.log")
  
end


