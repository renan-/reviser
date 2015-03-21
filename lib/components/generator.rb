require_relative 'generators'

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

			# Run the generation of results file in all asked formats by user.
			def run
				begin
					if Cfg[:out_format].respond_to? 'each'
						Cfg[:out_format].each { |f| send f.to_sym }
					else
						send Cfg[:out_format].to_sym
					end
				rescue Object => e
					@logger.h1 Logger::FATAL, "Wrong format : #{e.to_s}"
				end
			end

			# Get all criterias of marking
			# used to display informations in documents.
			# @return [Array] Array with all criterias.
			def criterias
				@data.values.first.keys.unshift.map! { |cri| Generator.titleize(cri.to_s) }
			end

			# Quite handy
			def self.titleize(str)
				str.split(/_/).join(' ').capitalize
			end

		end
	end
end