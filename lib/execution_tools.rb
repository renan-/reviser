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
	protected

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

		def exec(param = nil)
			program = (@cfg.has_key? :executable_name) ? @cfg[:executable_name] : findExecutable
			program = "./#{program}"
			argument = (param == nil) ? '' : param
			
			return 'Program not found' unless program != nil

			cmd = "#{(@cfg.has_key? :execute_command) ? @cfg[:execute_command] : ''} #{program} #{argument}"
			begin
				output = Timeout.timeout(@cfg[:timeout]) do
					Thread.new { `#{cmd}`; $?.exitstatus }.value
				end
			rescue Timeout::Error
				output = 'Timeout'
			end

			cmd + ' => ' + output.to_s
		end

		def findExecutable
			Dir.glob('*').select {|f| File.executable?(f) && !File.directory?(f)}.first
		end
end