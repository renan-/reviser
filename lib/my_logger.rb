require 'logger'
require_relative 'logger_mode'

# Custom logger of Reviser.
# This class is a adapter.
# We used the standard Logger included in Ruby.
#
# @author Yann Prono
#
class MyLogger

	# Create logger.
	# The extension determines the mode to use (logger mode).
	# @filename
	def initialize filename
		ext = File.extname(filename).delete '.'
		begin
			self.class.send :include, Object.const_get("LoggerMode::#{ext.downcase.capitalize}")
		rescue => e
			self.class.send :include, LoggerMode::Txt
		end
		@logger = Logger.new filename
		@logger.level = Logger::DEBUG
  	end

  	# Close the logger
  	def close
  		@logger.close
  	end

  	# In case of someone want to use methods of standard Logger ...
  	def method_missing(m, *args, &block)
		@logger.send(m,*args, &block)
  	end

end