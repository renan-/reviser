#
# Author:: Renan Strauss
#
# TODO
# Organise the checker around modules for
# each group of criterias (code, compilation, execution, and so on)
#
require 'fileutils'
require 'shellwords'
require 'open3'

require_relative 'compilation_tools'
require_relative 'component'
require_relative 'execution_tools'

class Checker < Component
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
	def compile
	end

	def check(proj)
		files = Dir.glob('*').select { |f| (File.file?(f)) }
		src_files = files.select { |f| @cfg[:extension].include? File.extname(f) }

		@results[proj] = {
			:fichiers => files.join("\r"),
			:fichiers_sources => src_files.join("\r"),
			:nombre_total_de_lignes_de_code => files.inject(0) { |sum, f|
				sum + File.open(f).readlines.select { |l|
					(!l.chomp.empty?) && (l.scrub !~ @cfg[:regex_comments])  
				}.size
			},
			:nombre_de_lignes_de_commentaires => src_files.inject([]) { |tab, f|
					tab << IO.read(f).scrub.scan(@cfg[:regex_comments])
				}.inject("") { |s, comm|
						s << comm.inject("") { |t, l|
							t << (l.size > 3 && l[3] + "\n") || ""
						}
				}.split("\n").size,
		}

		@results[proj][@cfg[:compiled] ? :resultats_compilation : :fichiers_manquants] = compile
		@results[proj][:resultats_execution] = execute

		@results
	end

	def exec_with_timeout(cmd, timeout = @cfg[:timeout])
		stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
		exitstatus = -1

		begin
			Timeout.timeout(@cfg[:timeout]) do
				exitstatus = wait_thr.value
			end
		rescue Timeout::Error
			$stdout << 'Timeout'
			begin
				Process.kill('KILL', wait_thr[:pid])
			rescue Object => e
				$stderr << "Unable to kill process : #{e.to_s}"
			end
		end

		return { :stdout => 'Timeout', :success => false} unless exitstatus != -1
		
		result = {
			:stdout => stdout.read,
			:stderr => stderr.read,
			:status => exitstatus,
			:success => exitstatus.success?
		}

		stdin.close  # stdin, stdout and stderr should be closed explicitly in this form.
		stdout.close
		stderr.close

		return result
	end
end