#
# Author:: Renan Strauss
#
# The Checker is a component that wraps
# all required tools to do the analysis.
# It adapts itself dynamically
# to the language Cfg.
#
#
require 'open3'

require_relative 'code_analysis_tools'
require_relative 'compilation_tools'
require_relative 'execution_tools'
require_relative 'criteria_manager'

class Checker < Component
	include CodeAnalysisTools
	include ExecutionTools

	def initialize(data)
		super data

		@results = {}

		if Cfg[:compiled]
			extend CompilationTools
		end
	end

	# Yann : je ne recupere pas les datas de l'organiser,
	# Je considere que tous les projets sont dans le dossier courant.
	# TODO a voir si cela marche dans certains cas particuliers
	def run
		# We'll work in the dest directory
		Dir.chdir Cfg[:dest] do
			projects = Dir.entries('.') - ['.','..']
			projects.each_with_index do |proj, i| 
				puts "\t[#{i+1}/#{projects.size}]\t#{proj}"
				Dir.chdir(proj) { check proj }
			end
		end

		@results
	end

private

	#
	# Being called in the project's directory,
	# this methods maps all the criterias to
	# their analysis value
	#
	def check(proj)
		cm = CriteriaManager.new
		cm.prepare Cfg[:criteria]
=begin		compile_key = (Cfg[:compiled] && :resultats_compilation || :fichiers_manquants)
		@results[proj] =
		{
			:fichiers => files.join("\r"),
			:fichiers_sources => src_files.join("\r"),
			:nombre_total_de_lignes_de_code => lines_count,
			:nombre_de_lignes_de_commentaires => comments_count,
			compile_key => Cfg[:compiled] && compile || prepare,
			:resultats_execution => execute
		}
=end
	end

	#
	# For interpreted languages
	# We only check for missing files
	#
	def prepare
		missing_files.empty? && 'None' || res
	end

	#
	# This method checks for required files
	# Typically needed for C with Makefile
	# 
	def missing_files
		return [] unless Cfg =~ :required_files

		dir = Dir['*']

		#
		# Check if there is any regexp
		# If it's the case, if any file
		# matches, we delete the entry
		# for diff to work properly
		#
		Cfg[:required_files].each_with_index do |e, i|
			if dir.any? { |f| (e.respond_to?(:match)) && (e =~ f) }
				Cfg[:required_files].delete_at i
			end
		end

		Cfg[:required_files] - dir
	end

	#
	# Executes the given command
	# and kills it if its execution
	# time > timeout
	# @returns stdout, stderr & process_status
	#
	def exec_with_timeout(cmd, timeout = Cfg[:timeout])
		stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
		process_status = -1

		stdin.close
		#
		# We try to wait for the thread to join
		# during the given timeout.
		# When the thread has joined, process_status
		# will be an object, so we can check and
		# return at the end if it failed to complete
		# before time runs out.
		#
		begin
			Timeout.timeout(timeout) do
				process_status = wait_thr.value
			end
		rescue Timeout::Error
			#
			# Then whether it suceeded or not,
			# we kill the process
			#
			begin
				Process.kill('KILL', wait_thr[:pid])
			rescue Object => e
				$stderr << "Unable to kill process : #{e.to_s}"
			end
		end

		result = {
			:stdout => process_status == -1 && 'Timeout' || stdout.read,
			:stderr => process_status == -1 && 'Timeout' || stderr.read,
			:process_status => process_status == -1 && 'Timeout' || process_status
		}
		
		result.delete :process_status unless process_status != -1

		stdout.close
		stderr.close

		result
	end
end