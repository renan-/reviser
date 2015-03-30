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
require 'open3'
require 'timeout'

module Reviser
	module Helpers
		#
		# Wraps methods for system calls
		# (external programs execution)
		# @author Renan Strauss
		#
		module System
			#
			# @return the first executable found
			#
			def find_executable
				Dir['*'].select { |f| File.executable?(f) && !File.directory?(f) }.first
			end

			#
			# Executes the given command
			# and kills it if its execution
			# time > timeout
			# @return stdout, stderr & process_status
			#
			def exec_with_timeout(cmd, timeout = Cfg[:timeout])
				stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
				process_status = -1

				stdin.close
				#
				# We try to wait for the thread to join
				# during the given timeout.
				# When the thread has joined, process_status
				# will be an object, so we can check and
				# return at the end if it failed to complete
				# before time runs out.
				#
				begin
					Timeout.timeout(timeout) do
						process_status = wait_thr.value
					end
				rescue Timeout::Error
					#
					# Then whether it suceeded or not,
					# we kill the process
					#
					begin
						Process.kill('KILL', wait_thr[:pid])
					rescue Object => e
						$stderr << "Unable to kill process : #{e.to_s}"
					end
				end

				result = {
					:stdout => process_status == -1 && 'Timeout' || stdout.read,
					:stderr => process_status == -1 && 'Timeout' || stderr.read,
					:process_status => process_status == -1 && 'Timeout' || process_status
				}
				
				result.delete :process_status unless process_status != -1

				stdout.close
				stderr.close

				result
			end
		end
	end
end