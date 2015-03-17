require 'logger'

#
# Modules containing all methods to custom logger.
# 
# There are 3 main level of logger (as in HTML)
# => h1
# => h2
# => h3

# @author Yann Prono
# @author Anthony Cerf
module Loggers
	module Modes

		module Txt

			include Modes

			def h1 severity, msg
				change_formatter ''
				@logger.add severity, msg
			end

			def h2 severity, msg
				change_formatter "\t\t"
				@logger.add severity, msg
			end

			def h3 severity, msg
				change_formatter "\t\t\t"
				@logger.add severity, msg
			end
		end

		module Org

			include Modes
			
			def h1 severity, msg
				change_formatter '*'
				@logger.add severity, msg
			end

			def h2 severity, msg
				change_formatter "**"
				@logger.add severity, msg
			end

			def h3 severity, msg
				change_formatter "***"
				@logger.add severity, msg
			end

		end

		# Change formatter
		# @param prefix Prefix to put before all content
		def change_formatter prefix
			@logger.formatter = proc do |severity, datetime, progname, msg|
				"\n#{prefix} #{severity} #{msg}"
			end
		end

		# Create new line
		def newline
			@logger.formatter = proc do |severity, datetime, progname, msg|
				"\n#{msg}"
			end
			@logger.add(nil,"\n")
		end

	end
end