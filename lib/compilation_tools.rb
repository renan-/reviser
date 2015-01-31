#
# @Author Yann Prono
# @Author Renan Strauss
#
# Needed stuff for compiled languages
# such as C, Java, and so on.
#

module CompilationTools
	protected

	def compile
		check = check_for_required_files
		if !check.respond_to? 'each'
			cmd = "#{@cfg[@cfg.has_key?(:preferred_build_command) ? :preferred_build_command : :default_build_command]}"
			out = exec_with_timeout "#{cmd}"

			if out.has_key? :process_status
				return "Exit status: 0\r#{out[:stdout]}" unless out[:process_status].exitstatus != 0
			end

			if @cfg.has_key? :preferred_build_command
				puts "FALLBACK\n#{@cfg[:default_build_command]}"
				out = exec_with_timeout "#{@cfg[:default_build_command]}"
			end

			(out[:process_status].exitstatus == 0) ? "Exit status: 0\r#{out[:stdout]}" : "#{out[:stdout]}\r#{out[:stderr]}"
		else
			"Missing file(s) : #{check}"
		end
	end

	def check_for_required_files
		if !@cfg.has_key? :required_files
			return true
		end

		diff = @cfg[:required_files] - Dir.glob('*')
		diff.empty? && true || diff
	end
end