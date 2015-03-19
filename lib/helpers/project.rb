#
# Provide important methods
# for compilation or something like that.
#
# @author Renan Strauss
# @author Yann Prono
#
module Helpers
	module Project
		#
		# For interpreted languages
		# We only check for missing files
		#
		def prepare
			missing_files.empty? && 'None' || res
		end

		# Check if the project has all files needed
		def missing_files
			return [] unless Cfg =~ :required_files

			dir = Dir['*']

			#
			# Check if there is any regexp
			# If it's the case, if any file
			# matches, we delete the entry
			# for diff to work properly
			#
			Cfg[:required_files].each_with_index do |e, i|
				if dir.any? { |f| (e.respond_to?(:match)) && (e =~ f) }
					Cfg[:required_files].delete_at i
				end
			end

			Cfg[:required_files] - dir
		end
	end
end