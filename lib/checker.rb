#
# Author:: Renan Strauss
#
# The Checker is a component that wraps
# all required tools to do the analysis.
# It adapts itself dynamically
# to the language config.
#
#
require 'open3'

require_relative 'code_analysis_tools'
require_relative 'compilation_tools'
require_relative 'component'
require_relative 'execution_tools'

class Checker < Component
	include CodeAnalysisTools
	include ExecutionTools

	def initialize(data)
		super data

		@results = {}

		if @cfg[:compiled]
			extend CompilationTools
		end
	end

	def run
		# We'll work in the dest directory
		Dir.chdir @cfg[:dest] do
			# The data we got from Organiser is a tab
			# which contains all the project folders.
			@data.each_with_index { |proj, i| 
				puts "\t[#{i+1}/#{@data.size}]\t#{proj}"
				Dir.chdir(proj) { check proj }
			}
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
		@results[proj] =
		{
			:fichiers => files.join("\r"),
			:fichiers_sources => src_files.join("\r"),
			:nombre_total_de_lignes_de_code => lines_count,
			:nombre_de_lignes_de_commentaires => comments_count,
			(@cfg[:compiled] && :resultats_compilation || :fichiers_manquants) => compile,
			:resultats_execution => execute
		}
	end

	#
	# For interpreted languages
	# We only check for missing files
	#
	def compile
		res = check_for_required_files
		res.empty? && 'None' || res
	end

	#
	# This method checks for required files
	# Typically needed for C with Makefile
	# 
	def check_for_required_files
		if !@cfg.has_key? :required_files
			return []
		end

		dir = Dir['*']

		#
		# Check if there is any regexp
		# If it's the case, if any file
		# matches, we delete the entry
		# for diff to work properly
		#
		@cfg[:required_files].each_with_index do |e, i|
			if dir.any? { |f| (e.respond_to?(:match)) && (e =~ f) }
				@cfg[:required_files].delete_at i
			end
		end

		@cfg[:required_files] - dir
	end

	#
	# Executes the given command
	# and kills it if its execution
	# time > timeout
	# @returns stdout, stderr & process_status
	#
	def exec_with_timeout(cmd, timeout = @cfg[:timeout])
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
			$stdout << 'Timeout'
			begin
				Process.kill('KILL', wait_thr[:pid])
			rescue Object => e
				$stderr << "Unable to kill process : #{e.to_s}"
			end

			return { :stdout => 'Timeout', :success => false} unless process_status != -1
		end
		
		result = {
			:stdout => stdout.read,
			:stderr => stderr.read,
			:process_status => process_status
		}

		stdout.close
		stderr.close

		return result
	end
end