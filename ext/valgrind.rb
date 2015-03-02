require_relative '../lib/utils'
require_relative '../lib/execution_tools'

module Valgrind

	include ExecutionTools

	include Utils

	#
	# Check memory leaks of the program
	# The module uses execution value written in the config file of the project 
	#
	def memleaks
		executable = find_executable
		program = "#{Cfg[:program_prefix]}#{executable}"
		param = Cfg.has_key?(:execution_value) ? Cfg[:execution_value].first : ''
		cmd = "valgrind --leak-check=full --track-origins=yes --show-reachable=yes #{program} #{param}"
		out = exec_with_timeout cmd
		"$ #{cmd}\r#{out[:stdout]}\r#{out[:stderr]}"
	end
end