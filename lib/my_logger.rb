require 'logger'
require_relative 'logger_mode'

class MyLogger

	def initialize filename
		ext = File.extname(filename).delete '.'
		begin
			self.class.send(:include, Object.const_get("LoggerMode::#{ext.capitalize}"))
		rescue => e
			self.class.send(:include, LoggerMode::Txt)
		end
		@logger = Logger.new(filename)
		@logger.level = Logger::DEBUG
  	end

def method_missing(m, *args, &block)  
		@logger.send(m,*args)
  	end

end