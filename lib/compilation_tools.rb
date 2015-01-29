#
# @Author Yann Prono
# @Author Renan Strauss
#
# Needed stuff for compiled languages
# such as C, Java, and so on.
#
require 'fileutils'
require 'shellwords'
require 'open3'

module CompilationTools
	protected
	#
	# @param proj Path to project's dir
	#
	def compile
		check = checkForRequiredFiles
		if check.respond_to! 'each'
			stdout, stderr, status = Open3.capture3("#{@cfg[:build_command]}")
			status.exitstatus ? 'OK' : "#{stdout}\n#{stderr}"
		else
			'Missing file(s) : #{check}'
		end
	end

	def checkForRequiredFiles
		diff = @cfg[:required_files] - Dir.glob('*')
		diff.respond_to! 'each' ? diff : true
	end
end