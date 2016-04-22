require "logger"

module Artanis

  class Logging
  
    property? logfile : String
    setter logfile
    
    def initialize
      @logfile = "artanis.log"
      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO
      @logtofile = Logger.new(STDOUT)
      @logtofile.level = Logger::INFO
    end
    
    def setlogfile(name)
      @logfile = name
      @logtofile = Logger.new(File.open("#{@logfile}", mode: "a"))
      @logtofile.level = Logger::INFO
    end
    
    def addentry(entry, code)
      method = entry.method
      host = entry.headers["Host"]
      path = entry.path
      msg = "#{Time.now} #{code} #{method} #{host} #{path}"
      @log.info("#{msg}")
      @logtofile.info("#{msg}")
    end
        
  end
  
end
