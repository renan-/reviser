#
#   Reviser => a semi-automatic tool for student's projects evaluation
#
#   Copyright (C) 2015 Renan Strauss
#   Copyright (C) 2015 Yann Prono
#   Copyright (C) 2015 Romain Ruez
#   Copyright (C) 2015 Anthony Cerf
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'logger'

module Reviser
	module Loggers

		#
		# Module containing all methods to custom logger.
		# 
		# There are 3 main levels of logger
		# => h1	: Big title
		# => h2	: medium title
		# => h3	: tiny title	
		#
		# @author Yann Prono
		# @author Anthony Cerf
		# @author Romain Ruez
		#
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
			
			module Html
				include Modes

				@add_header = false
				def header
					add_tag "<!DOCTYPE html><html><head>
					<meta charset= \"UTF-8\">
					<link rel=\"stylesheet\" href=\"#{Cfg.resource('reviser/css/style_logs.css').to_path}\" />
					<title>#{@basename} logs</title>
					</head>\n<body>
					<header>
						<p>#{@basename} logs</p>\n</header>\n<section>"
					@add_header = true
				end

				def h1 severity,msg
					header unless @add_header
					change_formatter "<h1 class=\"#{severity_to_s(severity)}\">" , '</h1>'
					@logger.add severity , msg
				end
				
				def h2 severity,msg
					header unless @add_header
					change_formatter "<h2 class=\"#{severity_to_s(severity)}\">" , '</h2>'
					@logger.add severity , msg
				end
				
				def h3 severity,msg
					header unless @add_header
					change_formatter "<h3 class=\"#{severity_to_s(severity)}\">", '</h3>'
					@logger.add severity , msg
				end

				def close
					add_tag '</section></body></html>'
					@logger.close
				end
				
			end
			
			
			# Changes formatter of logger.
			# @param prefix [String] Prefix to put before any content.
			# @param suffix [String] Suffix to put after all contents.
			def change_formatter prefix , suffix = ''
				@logger.formatter = proc do |severity, datetime, progname, msg|
					"\n#{prefix} #{severity} #{msg} #{suffix}"
				end
			end

			# Creates a new line.
			def newline
				@logger.formatter = proc do |severity, datetime, progname, msg|
					"\n#{msg}"
				end
				@logger.add(nil,"\n")
			end

			# Mainly used for HTML mode.
			# @param tag [String] tag added.
			def add_tag tag
				@logger.formatter = proc do |severity, datetime, progname, msg|
					"\n#{msg}"
				end
				@logger.add(nil,tag)
			end

			# converts a severity level to a String.
			# @param severity [Integer] Level of severity.
			# @return [String] String of severity.
			def severity_to_s severity
				sev_labels = %w(DEBUG INFO WARN ERROR FATAL ANY)
				sev_labels[severity].downcase
			end

		end
	end
end