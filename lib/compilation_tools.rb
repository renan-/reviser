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
			
			return "Exit status: #{out[:exitstatus]}" unless out[:success]

			if @cfg.has_key? :preferred_build_command
				out = exec_with_timeout "#{@cfg[:default_build_command]}"
			end

			out[:success] ? "Exit status: #{out[:process_status].exitstatus}" : "#{out[:stdout]}\r#{out[:stderr]}"
		else
			"Missing file(s) : #{check}"
		end
	end

	def check_for_required_files
		diff = @cfg[:required_files] - Dir.glob('*')
		!diff.respond_to?('each') ? diff : true
	end
end