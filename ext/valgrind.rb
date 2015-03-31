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

#
# @author Yann Prono
#
module Reviser
	module Extensions
		module Valgrind
			include Helpers::System

			VALGRIND_FILE = "valgrind.txt"

			#
			# Check memory leaks of the program
			# The module uses execution value written in the config file of the project
			#
			# Yann, execution_count shall be taken in count imo 
			#
			def memleaks
				executable = find_first_executable
				program = "#{Cfg[:program_prefix]}#{executable}"
				param = Cfg.has_key?(:execution_value) ? Cfg[:execution_value].first : ''
				cmd = "valgrind --leak-check=full --track-origins=yes --show-reachable=yes #{program} #{param}"
				out = exec_with_timeout cmd
				File.open(VALGRIND_FILE, 'w') { |f| f.write "$ #{cmd}\r#{out[:stdout]}\r#{out[:stderr]}" }
				
				result = File.join(FileUtils.pwd, VALGRIND_FILE)
				manufacture do |format|
					format.html { '<a href="' + result + '" target="_blank">' + result + '</a>' }
					format.csv { result }
					format.xls { result }
				end
			end
		end
	end
end