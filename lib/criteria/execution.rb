#
# @Author Renan Strauss
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
							outputs << exec(v)
						end
					else
						if Cfg.has_key? :execution_count
							outputs[Cfg[:execution_value]] = []
							Cfg[:execution_count].times do
								outputs << exec(Cfg[:execution_value])
							end
						else
							outputs << exec(Cfg[:execution_value])
						end
					end
				else
						if Cfg.has_key? :execution_count
							Cfg[:execution_count].times do
								outputs << exec
							end
						else
							return exec
						end
				end

				outputs.join("\r")
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
			def exec(param = nil)
				program = (Cfg.has_key? :program_name) && Cfg[:program_name] || find_executable

				return 'Program not found' unless program != nil

				program = "#{Cfg[:program_prefix]}#{program}"
				argument = (param == nil) && '' || param

				cmd = "#{(Cfg.has_key? :execute_command) && Cfg[:execute_command] || ''} #{program} #{argument}"
				out = exec_with_timeout cmd
				
				"$ #{cmd}\r#{out[:stdout]}\r#{out[:stderr]}"
			end
		end
	end
end