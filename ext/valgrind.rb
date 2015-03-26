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
				executable = find_executable
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