#
#   Reviser => a semi-automatic tool for student's projects evaluation
#
#   Copyright (C) 2015 Renan Strauss
#   Copyright (C) 2015 Yann Prono
#   Copyright (C) 2015 Romain Ruez
#   Copyright (C) 2015 Anthony Cerf
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'open3'

require_relative '../result'
require_relative '../helpers/criteria'

module Reviser
	module Components
		#
		# @author Renan Strauss
		#
		# The Checker is a component that wraps
		# all required tools to do the analysis.
		# It adapts itself dynamically
		# to the configuration
		#
		#
		class Checker < Component
			include Helpers::Criteria

			def initialize(data)
				super data

				@criteria = Hash.new
				@output = Hash.new

				@logger.h1 Logger::INFO, "Loading modules"

				load_modules CRITERIA
				load_modules EXTENSIONS

				#
				# We also load user-registered extensions if any
				#
				Reviser.registered_extensions.each do |ext|
					load_module_methods ext
				end

				@logger.h1 Logger::INFO, "Loading labels"

				[:criteria, :extensions].each { |x| load_labels x }

				@results = {}
			end

			#
			# For each project processed by Organiser,
			# we run analysis and store results
			#
			def run
				@data.each_with_index do |proj, i|
					path = File.join(Cfg[:dest], proj)
					puts "----[#{i+1}/#{@data.size}]\t#{proj}"
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