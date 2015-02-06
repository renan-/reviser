require 'fileutils'

# Module used for managing all actions in command line
module Exec

	# path of config template file.
	$template_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),'config.yml')

	# Say hello to the user !
	def hello
		puts 'Hello, this is my app'
	end

	# Get the action of user and execute the good action
	# TODO
	def exec(*argv)
		unless argv[0].empty?
			self.send(argv[0].first)
		end
	end

	# Create a environnment for checking projects
	# This method only copies the config file into the current directory.
	def init
		pwd = FileUtils.pwd		
		FileUtils.cp($template_path,pwd)
		print "\n\tCreate\t#{File.basename $template_path}\n\n"
	end


	# In case of the action is unknown
	def method_missing(m, *args, &block)  
		puts "Usage:\n\tapp <action> <paramaters>*"
		puts "\nParamaters could be optionnal."
		puts "\nActions :"
		ls = Exec.instance_methods(true) - [:method_missing, :exec]
		ls.each { |action| puts "\t#{action}" }
  	end

end
