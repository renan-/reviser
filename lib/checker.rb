require_relative 'component'
require 'fileutils'
require 'shellwords'
require 'open3'

#
# Author:: Renan Strauss
#
# TODO
# Organise the checker around modules for
# each group of criterias (code, compilation, execution, and so on)
#
require_relative 'compilation_tools'

class Checker < Component
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
			@data.each { |proj| Dir.chdir(proj) { check proj } }
		end

		@results
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
			
			:compilation =>	build(proj)
		}

		@results[proj][@cfg[:compiled] ? :resultats_compilation : :fichiers_manquants] = compile proj

		@results
	end

	# Build the current project
	# @param current_proj [String] the current project
	# This currently works for only C.
	#
	def build(current_proj)
		results = ''
		# Check if a makefile exists
		makefile = Dir.glob('?akefile').first
		
		if(makefile)
			# Launch make and capture output, errors and exist status
			stdout, stderr, status = Open3.capture3("#{@cfg[:build_command]}") 
			results =  status.exitstatus ? 'Build ok' : 'build problems (see logs)'
			# log stdout and stderr into file
			log = File.open('build_output.txt', "w")
			log << stdout
			log << stderr
			log.close
		else
			results = 'No makefile'
		end
		
		return results
	end

end