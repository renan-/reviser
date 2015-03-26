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
								arg[project][criterion] = value.send(format.to_sym)
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