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
require 'cgi'

module Reviser
	module Criteria
		#
		# @author Yann Prono
		# @author Renan Strauss
		#
		# Needed stuff for compiled languages
		# such as C, Java, and so on.
		#
		module Compilation
			include Helpers::System
			
			#
			# Only here for compiled language,
			#
			def compile
				raise Exception, "#{Cfg[:language]} is not a compiled language" unless Cfg[:compiled]
				#
				# For now, we compile only if there's
				# no missing file
				# We should maybe make it more
				# understandable in the Cfg
				#
				if missing_files.empty?
					result = ''

					cmd = "#{Cfg[Cfg.has_key?(:preferred_build_command) && :preferred_build_command || :default_build_command]}"
					out = exec_with_timeout cmd

					if out.has_key? :process_status
						result = "Exit status: 0\r#{out[:stdout]}" unless out[:process_status].exitstatus != 0
					else
						if Cfg.has_key? :preferred_build_command
							out = exec_with_timeout Cfg[:default_build_command]
						end
					end

					result = "#{out[:stdout]}\r#{out[:stderr]}"

					manufacture do |format|
						format.html { '<div class="console">' + ::CGI.escapeHTML(result) + '</div>' }
						format.csv { result }
						format.xls { result }
					end
				end
			end
		end
	end
end