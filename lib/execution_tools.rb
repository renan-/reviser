#
# @Author Renan Strauss
#
# Needed stuff for Checker
# when it comes to executing
# both compiled and interpreted
# languages
#

require 'mkmf'
require 'timeout'

module ExecutionTools
	#
	# Determines how to execute the program
	# thanks to config, then returns its exec
	# status(es)
	#
	def execute
		outputs = []
		if @cfg.has_key? :execution_value
			if @cfg[:execution_value].respond_to? 'each'
				@cfg[:execution_value].each do |v|
					outputs << exec(v)
				end
			else
				if @cfg.has_key? :execution_count
					outputs[@cfg[:execution_value]] = []
					@cfg[:execution_count].times do
						outputs << exec(@cfg[:execution_value])
					end
				else
					outputs << exec(@cfg[:execution_value])
				end
			end
		else
				if @cfg.has_key? :execution_count
					@cfg[:execution_count].times do
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
	# in the config, it executes the
	# first executable found.
	# It helps with C (a.out) when no 
	# Makefile is avalaible, but it
	# might not be a good idea regarding
	# security
	#
	def exec(param = nil)
		program = (@cfg.has_key? :program_name) ? @cfg[:program_name] : find_executable

		return 'Program not found' unless program != nil

		program = "#{@cfg[:program_prefix]}#{program}"
		argument = (param == nil) ? '' : param

		cmd = "#{(@cfg.has_key? :execute_command) ? @cfg[:execute_command] : ''} #{program} #{argument}"
		out = exec_with_timeout cmd
		
		"$ #{cmd}\r#{out[:stdout]}\r#{out[:stderr]}"
	end

	#
	# @return the first executable found
	#
	def find_executable
		Dir.glob('*').select {|f| File.executable?(f) && !File.directory?(f)}.first
	end
end