require 'thor'
require 'fileutils'

%w(config checker reviser exec).each do |lib|
	require_relative "#{lib}"
end

# Module used for managing all actions in command line
# This module enables to user the programm in command line.
# It use the powerful toolkit Thor for building  command line interfaces
#
# @author Yann Prono
class Exec < Thor

	# path of config template file.
	$template_path = File.join(File.dirname(File.dirname(__FILE__)),'config.yml')


	# Say hello to the user !
	desc 'hello','Say hello to the user !'
	def hello
		puts 'Hello, this is my app'
	end


	# Create a environnment for checking projects
	# This method only copies the config file into the current directory.
	desc 'init DIRECTORY', 'Create a new App project. By default,DIRECTORY is the current.'
	def init(dir = '.')
		pwd = FileUtils.pwd
		msg = File.exist?(File.join(pwd,dir,File.basename($template_path))) ? 'Recreate' : 'Create'
		FileUtils.mkdir_p dir unless Dir.exist?(File.join(pwd,dir))
		FileUtils.cp($template_path, dir)
		message(msg, File.basename($template_path))
	end


	# Clean the directory of logs, projects and results.
	desc 'clean', 'Delete datas creating by the App (logs, projects, results files ...).'
	def clean
		if(File.exist? 'config.yml')
			Cfg.load 'config.yml'
			FileUtils.rm_rf(Cfg[:dest], :verbose => true)
			FileUtils.rm_rf('logs', :verbose => true)
			#!!! Why not *.#{format} ! and why not rm_f instead of rm_rf (output is never a directory)
			Cfg[:out_format].each {|format| FileUtils.rm_rf(Dir["*#{format}"], :verbose => true) unless Dir["*#{format}"].empty?}
		end
	end


	# Let do it for analysis.
	# @param current_dir [String] the directory where the programm has to be launched.
	desc 'work', 'Run components to analysis computing projects.'
	def work
		setup_reviser

		# TODO Maybe not the good place to put this code
		path_res = File.join(File.dirname(File.dirname(__FILE__)),"#{Cfg[:res_dir]}")
		FileUtils.cp_r(path_res,FileUtils.pwd)

		Reviser::load :component => 'archiver'
		Reviser::load :component => 'organiser'
		Reviser::load :component => 'checker', :inputFrom => 'organiser'
		Reviser::load :component => 'generator', :inputFrom => 'checker'

		Reviser::run
	end

	# Launch archiver !
	desc 'extract', 'Launch archiver and extract all projects.'
	def extract
		setup_reviser
		Reviser::load :component => 'archiver'
		Reviser::run
	end

	# Launch organiser !
	desc 'organise', 'Launch organiser and prepare all projects for analysis'
	def organise
		setup_reviser
		Reviser::load :component => 'organiser'
		Reviser::run
	end

	# Launch checker and generator as well !
	desc 'check', 'Launch checker for analysis and generate results.'
	def check
		setup_reviser
		Reviser::load :component => 'checker'
		Reviser::load :component => 'generator', :inputFrom => 'checker'
		Reviser::run
	end


	no_tasks do
  		# A Formatter message for command line
  		def message(keyword, desc)
  			puts "\t#{keyword}\t\t#{desc}"
		end

		def setup_reviser
			config_file = File.expand_path('config.yml')
			Reviser::setup config_file
		end

	end

end

Exec.start(ARGV)