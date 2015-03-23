require 'logger'
require_relative 'modes'

# Custom logger of Reviser.
# This class is a adapter.
# We used the standard Logger included in Ruby.
#
# @author Yann Prono
#
module Reviser
	module Loggers

		class Logger::LogDevice
			def add_log_header(file)
			end
		end

		class Logger

			# Create logger.
			# The extension determines the mode to use (logger mode).
			# @filename
			def initialize filename
				ext = File.extname filename
				@basename = File.basename filename, ext
				ext = ext.delete '.'
				# Include mode aksed by user (config file)
				begin
					self.class.send :prepend, Modes.const_get("#{ext.downcase.capitalize}")
				rescue => e
					self.class.send :include, Modes::Txt
				end

				@logger = ::Logger.new File.open(filename, 'w')
				@logger.level = ::Logger::DEBUG
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
	end
end