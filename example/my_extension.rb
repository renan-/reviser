#
# A custom criteria for reviser
#
require '../lib/reviser'

module MyExtension
	#
	# This helper has the 'sources' methods
	# that allow you to retrieve all sources
	# files (files matching language extension)
	#
	include Reviser::Helpers::Project

	def my_criteria
		results = []
		sources.each do |f|
			results << f
		end

		#
		# The manufacture method excepts
		# a block which must describe the result contents
		# for EACH format.
		# You can also return raw data, then it'll be as it is
		# for all formats.
		#
		manufacture do |format|
			format.html { to_html results }
			format.csv { ['This', 'is', 'power', 'of', 'Ruby', 'blocks'] }
			format.xls { results }
		end
	end

	private
		#
		# We just create a HTML list
		#
		def to_html data
			html = '<ul>'
			data.each do |el|
				html << "<li>#{el}</li>"
			end
			html << '</ul>'

			html
		end
end
