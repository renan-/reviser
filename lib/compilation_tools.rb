#
# @Author Yann Prono
# @Author Renan Strauss
#
# Needed stuff for compiled languages
# such as C, Java, and so on.
#

module CompilationTools
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
			cmd = "#{Cfg[(Cfg.has_key? :preferred_build_command) && :preferred_build_command || :default_build_command]}"
			out = exec_with_timeout cmd

			if out.has_key? :process_status
				return "Exit status: 0\r#{out[:stdout]}" unless out[:process_status].exitstatus != 0
			end

			if Cfg.has_key? :preferred_build_command
				out = exec_with_timeout Cfg[:default_build_command]
			end

			(out[:process_status].exitstatus == 0) ? "Exit status: 0\r#{out[:stdout]}" : "#{out[:stdout]}\r#{out[:stderr]}"
		end
	end
end