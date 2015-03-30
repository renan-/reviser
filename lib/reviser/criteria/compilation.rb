#
# @author Yann Prono
# @author Renan Strauss
#
# Needed stuff for compiled languages
# such as C, Java, and so on.
#

module Reviser
	module Criteria
		module Compilation
			include Helpers::System
			
			#
			# Only here for compiled language,
			#
			def compile
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
						format.html { '<div class="console">' + result + '</div>' }
						format.csv { result }
						format.xls { result }
					end
				end
			end
		end
	end
end