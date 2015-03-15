require 'logger'

module LoggerMode

	module Txt

		include LoggerMode

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

		include LoggerMode

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


	def change_formatter prefix
		@logger.formatter = proc do |severity, datetime, progname, msg|
			"#{prefix} #{severity} #{msg}\n"
		end
	end

end
