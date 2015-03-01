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

require_relative 'criteria_manager'

class Checker < Component
	
	# Manager of criteria
	@crit_manager

	def initialize(data)
		super data
		
		@results = {}
		@crit_manager = CriteriaManager.new
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
		# Init results
		@results[proj] = {}
		
		# for each method asked by user with its label
		@crit_manager.criteria.each do |meth, label|
			@results[proj][label] = @crit_manager.call meth
		end
	end

end