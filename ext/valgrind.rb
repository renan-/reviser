module Extensions
	module Valgrind

		include Helpers::Execution
		include Helpers::System

		VALGRIND_FILE = "valgrind.txt"

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
			File.open(VALGRIND_FILE, 'w') { |f| f.write "$ #{cmd}\r#{out[:stdout]}\r#{out[:stderr]}" }
			File.join(FileUtils.pwd, VALGRIND_FILE)
		end

	end
end