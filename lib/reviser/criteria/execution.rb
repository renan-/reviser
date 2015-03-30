#
# @author Renan Strauss
#
# Needed stuff for Checker
# when it comes to executing
# both compiled and interpreted
# languages
#

require 'timeout'

module Reviser
	module Criteria
		module Execution
			#
			# Determines how to execute the program
			# thanks to Cfg, then returns its exec
			# status(es)
			#
			def execute
				outputs = []
				if  Cfg.has_key? :execution_value
					if Cfg[:execution_value].respond_to? 'each'
						Cfg[:execution_value].each do |v|
							outputs << make_exec(v)
						end
					else
						if Cfg.has_key? :execution_count
							outputs[Cfg[:execution_value]] = []
							Cfg[:execution_count].times do
								outputs << make_exec(Cfg[:execution_value])
							end
						else
							outputs << make_exec(Cfg[:execution_value])
						end
					end
				else
						Cfg[:execution_count].times do
							outputs << make_exec
						end
				end

				result = outputs.join("\r")
				manufacture do |format|
					format.html { '<div class="console">' + result + '</div>' }
					format.csv { result }
					format.xls { result }
				end
			end

		private

			#
			# The method that actually
			# executes the program.
			# If no program name is specified
			# in the Cfg, it executes the
			# first executable found.
			# It helps with C (a.out) when no 
			# Makefile is avalaible, but it
			# might not be a good idea regarding
			# security
			#
			def make_exec param = ''
				program = (Cfg.has_key? :program_name) && Cfg[:program_name] || find_executable

				return 'Program not found' unless program != nil

				program = "#{Cfg[:program_prefix]}#{program}"

				cmd = "#{Cfg[:execute_command]} #{program} #{param}"
				out = exec_with_timeout cmd
				
				"$ #{cmd}\r#{out[:stdout]}\r#{out[:stderr]}"
			end
		end
	end
end