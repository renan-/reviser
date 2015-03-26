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

require_relative '../result'

module Reviser
	module Components
		class Checker < Component
			include Helpers::Criteria

			def initialize(data)
				super data

				@criteria = Hash.new
				@output = Hash.new

				@logger.h1 Logger::INFO, "Loading modules"

				load CRITERIA
				load EXTENSIONS

				@logger.h1 Logger::INFO, "Loading labels"

				[:criteria, :extensions].each { |x| load_labels x }

				@results = {}
			end

			# Yann : je ne recupere pas les datas de l'organiser,
			# Je considere que tous les projets sont dans le dossier courant.
			# TODO a voir si cela marche dans certains cas particuliers
			def run
				@data.each_with_index do |proj, i|
					path = File.join(Cfg[:dest], proj)
					puts "\t[#{i+1}/#{@data.size}]\t#{proj}"
					Dir.chdir(path) { check proj }
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
						result = call meth
						data = result.is_a?(Result) && result || Result.new(result)
						@results[proj][label] = data
					else
						@logger.h1(Logger::ERROR, "Unknown method '#{meth}'' for project #{proj}")
					end
				end
			end
		end
	end
end