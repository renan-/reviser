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

require_relative 'criteria_helper'

class Checker < Component
	include CriteriaHelper

	def initialize(data)
		super data

		init_criteria_helper

		@results = {}
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
		@output.each do |meth, label|
			if @criteria.has_key? meth
				@results[proj][label] = call meth 
			else
				@logger.error { "Unknown method '#{meth}'' for project #{proj}" }
			end
		end
	end

	#
	# This method is what would be the constructor
	# of criteria_helper if it was a class
	#
	def init_criteria_helper
		@criteria = Hash.new
		@output = Hash.new

		load PWD, '*tool*'
		load EXT, '*'

		[:criteria, :extensions].each { |x| load_labels x }
	end

end