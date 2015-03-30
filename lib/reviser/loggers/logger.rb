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
require_relative 'modes'

module Reviser
	module Loggers

		class Logger::LogDevice
			def add_log_header(file)
			end
		end

		# Custom logger of Reviser.
		# This class is a adapter.
		# We used the standard Logger included in Ruby.
		#
		# @author Yann Prono
		#
		class Logger

			# Creates logger.
			# The extension determines the mode to use (logger mode).
			# @param filename [String] name of logger.
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

		  	# Closes the logger
		  	def close
		  		@logger.close
		  	end

		  	# In case of someone want to use methods of standard Logger ...
		  	def method_missing(m, *args, &block)
					@logger.send m, *args, &block
		  	end
		end
	end
end