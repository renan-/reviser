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
			
			exit_status = @cfg.has_key? :compilation_exit_status ? @cfg[:compilation_exit_status] : 0
			return "Exit status: #{out[:exitstatus]}"  unless (out[:exitstatus] == exit_status)

			if @cfg.has_key? :preferred_build_command
				out = exec_with_timeout "#{@cfg[:default_build_command]}"
			end

			"#{(out[:exitstatus] == exit_status) ? "OK\rexit status: #{out[:exitstatus]}" : out[:output].to_s}"
		else
			"Missing file(s) : #{check}"
		end
	end

	def check_for_required_files
		diff = @cfg[:required_files] - Dir.glob('*')
		!diff.respond_to?('each') ? diff : true
	end
end