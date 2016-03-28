module Artanis

  class Logging
  
    property? logfile : String
    setter logfile
    
    def initialize
      @logfile = "artanis.log"
    end
    
    def setlogfile(name)
      @logfile = name
    end
    
    def openfile(filename, entry)
      File.open("#{filename}", mode: "a") {|n|
        n.puts(entry)
      }
    end
    
    def addentry(entry, code)
      method = entry.method
      host = entry.headers["Host"]
      path = entry.path
      msg = "#{Time.now} #{code} #{method} #{host} #{path}"
      puts msg
      openfile(@logfile, msg)
    end
        
  end
  
end
