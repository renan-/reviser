require 'fileutils'

# Module used for managing all actions in command line
# This module enables to user the programm in command line.
#
# @author Yann Prono
module Exec

	# path of config template file.
	$template_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),'config.yml')

	# Say hello to the user !
	def hello
		puts 'Hello, this is my app'
	end

	# Get parameters of user and execute the good action
	# TODO
	# - multiple parameters
	# - Others actions
	def exec(*argv)
		self.send(argv[0].first) unless argv[0].empty?
	end

	# Create a environnment for checking projects
	# This method only copies the config file into the current directory.
	def init
		message = "#{File.basename $template_path}\n\n"
		exist = File.exist?(File.join(FileUtils.pwd,'config.yml'))
		FileUtils.rm 'config.yml' if exist
		FileUtils.cp($template_path,FileUtils.pwd) unless exist
		puts (exist ? "\n\tRecreate\t"+message : "\n\tCreate\t"+message)
	end

	# Let do it for analysis.
	# @param current_dir [String] the directory where the programm has to be launched.
	def run(current_dir = '.')
		config_file = File.expand_path('config.yml')

		Reviser::setup config_file

		# !!! Reviser's run method relies
		# on Ruby 1.9+ implementation of
		# iteration over hashes, which
		# ensures that the hash is iterated
		# accordingly to the insertion order
		Reviser::load :component => 'archiver'
		Reviser::load :component => 'organiser'
		Reviser::load :component => 'checker', :inputFrom => 'organiser'
		Reviser::load :component => 'generator', :inputFrom => 'checker'

		Reviser::run
	end


	# In case of the action is unknown,
	# print help.
	def method_missing(m, *args, &block)  
		puts "Usage:\n\tapp <action> <paramaters>*"
		puts "\nParamaters could be optionnal."
		puts "\nActions :"
		ls = Exec.instance_methods(true) - [:method_missing, :exec]
		ls.each { |action| puts "\t#{action}" }
  	end

end
