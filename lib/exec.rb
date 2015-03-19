require 'thor'
require 'fileutils'

require_relative 'reviser'
require_relative 'helpers/criteria'

#
# Module used for managing all actions in command line
# This module enables to user the programm in command line.
# It use the powerful toolkit Thor for building  command line interfaces
#
# @author Yann Prono
#
class Exec < Thor

	@@setup = false

	# path of config template file.
	$template_path = File.join(File.dirname(File.dirname(__FILE__)),'config.yml')

	def initialize(*args)
		super
		# If config.yml already exists in the working
		# directory, then we setup reviser here
		config_file = File.expand_path('config.yml')
    	setup config_file if File.exist? config_file
	end


	# Say hello to the user !
	desc 'hello','Say hello to the user !'
	def hello
		puts 'Hello, I am reviser'
	end


	# Create a environnment for checking projects
	# This method only copies the config file into the current directory.
	desc 'init DIRECTORY', 'Initialise workspace. DIRECTORY ||= \'.\''
	def init(dir = '.')
		pwd = FileUtils.pwd
		msg = File.exist?(File.join(pwd,dir,File.basename($template_path))) && 'Recreate' || 'Create'
		FileUtils.mkdir_p dir unless Dir.exist?(File.join(pwd, dir))
		FileUtils.cp($template_path, dir)
		message(msg, File.basename($template_path))

    	setup File.expand_path(File.join(dir, File.basename($template_path))) unless @@setup
	end


	# Clean the directory of logs, projects and results.
	desc 'clean', 'Delete generated data (logs, projects, results files ...)'
	def clean
		if File.exist? 'config.yml'
			FileUtils.rm_rf(Cfg[:dest], :verbose => true)
			if Cfg.has_key?(:options) && Cfg[:options].has_key?(:log_dir)
				FileUtils.rm_rf(Cfg[:options][:log_dir], :verbose => true)
			else
				FileUtils.rm_f(Dir['*.txt'], :verbose => true)
			end

			if Cfg[:out_format].respond_to? 'each'
				Cfg[:out_format].each { |format| FileUtils.rm_f(Dir["*.#{format}"], :verbose => true) }
			else
				FileUtils.rm_f(Dir["*.#{Cfg[:out_format]}"], :verbose => true)
			end

			FileUtils.rm_rf(Cfg[:res_dir], :verbose => true)
		else
			message("Error", "'config.yml' doesn't exist! Check if you are in the good directory.")
		end

	end


	# Let do it for analysis.
	# @param current_dir [String] the directory where the programm has to be launched.
	desc 'work', 'Run components to analysis computing projects'
	def work
		Reviser::load :component => 'archiver'
		Reviser::load :component => 'organiser', :inputFrom => 'archiver'
		Reviser::load :component => 'checker', :inputFrom => 'organiser'
		Reviser::load :component => 'generator', :inputFrom => 'checker'

		Reviser::run
	end

	#
	# For the moment, associate a label to a criterion (method).
	#
	# Cette methode me fait penser qu'on devrait vraiment configurer
	# le dossier de base ici, et le passer dans la config parce que,
	# par defaut, les modifs sur le fichier labels.yml seront faites
	# sur le fichier labels.yml dans le dossier ou est le programme,
	# et non dans le dossier ou travaille l'utilisateur
	#
	desc 'add METH \'LABEL\'', 'Associates LABEL with METH analysis def'
	def add meth, label
		res = Criteria::Labels.add meth, label
		message "#{res} label",meth + " => " + label
	end


	no_tasks do
  		# A Formatter message for command line
  		def message(keyword, desc)
  			puts "\t#{keyword}\t\t#{desc}"
		end

		def setup(config_file)
			Reviser::setup config_file

			path_res = File.join(File.dirname(File.dirname(__FILE__)),"#{Cfg[:res_dir]}")
			FileUtils.cp_r(path_res, FileUtils.pwd)

			@@setup = true
		end
	end

end

Exec.start(ARGV)