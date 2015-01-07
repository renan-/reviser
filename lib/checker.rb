#
# Author:: Renan Strauss
#

class Checker < Component
	def initialize(data)
		super data

		@results = {}
	end

	def run
		# We'll work in the dest directory
		Dir.chdir @Cfg[:dest] do
			# The data we got from Organiser is a tab
			# which contains all the project folders.
			@data.each do |proj|
				Dir.chdir proj do
					@results[proj] = { :files => Dir.glob('*') }
				end
			end
		end

		return @results
	end
end