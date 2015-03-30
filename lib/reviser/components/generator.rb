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
require_relative 'generators'
require_relative '../result'

module Reviser
	module Components

		# Generator is used to create a file result after the analysis.
		# Currently, Generator supports HTML, XLS and CSV format.
		#
		# @author 	Renan Strauss
		# @author 	Yann Prono
		#
		class Generator < Component
			
			# Include all supported formats
			include Generators

			def initialize(data)
				super data
			end

			# Runs the generation of results file in all asked formats by user.
			def run
				#begin
					Cfg[:out_format].each do |format|
						# Deep copy !!!
						arg = Marshal.load(Marshal.dump(@data))
						arg.each do |project, results|
							results.each do |criterion, value|
								arg[project][criterion] = value.send(format.to_sym).to_s.encode! 'utf-8', :invalid => :replace
							end
						end

						send format.to_sym, arg
					end
				#rescue Object => e
				#	@logger.h1 Logger::FATAL, "Wrong format : #{e.to_s}"
				#end
			end

			# Gets all criterias of marking
			# used to display informations in documents.
			# @return [Array] Array with all criterias.
			def criterias
				@data.values.first.keys.unshift.map! { |cri| Generator.titleize(cri.to_s) }
			end

			# Quite handy
			# @param str [String] string to titleize
			# @return [String] cute string !
			def self.titleize(str)
				str.split(/_/).join(' ').capitalize
			end

		end
	end
end