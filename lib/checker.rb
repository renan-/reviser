#
# Author:: Renan Strauss
#
# TODO
# Organise the checker around modules for
# each group of criterias (code, compilation, execution, and so on)
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

	# For interpreted languages
	# We only check for missing files
	def compile
		res = check_for_required_files
		res.empty? && 'None' || res
	end

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

	def exec_with_timeout(cmd, timeout = @cfg[:timeout])
		stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
		process_status = -1

		stdin.close
		begin
			Timeout.timeout(timeout) do
				process_status = wait_thr.value
			end
		rescue Timeout::Error
			return { :stdout => 'Timeout', :success => false} unless process_status != -1
			
			$stdout << 'Timeout'
			begin
				Process.kill('KILL', wait_thr[:pid])
			rescue Object => e
				$stderr << "Unable to kill process : #{e.to_s}"
			end
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