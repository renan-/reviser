#
# A custom criteria for reviser
#
require '../lib/reviser'

module MyExtension
	include Reviser::Helpers::Project

	def my_criteria
		results = []
		sources.each do |f|
			results << f
		end

		manufacture do |format|
			format.html { to_html results }
			format.csv { ['This', 'is', 'power', 'of', 'Ruby', 'blocks'] }
			format.xls { results }
		end
	end

	private
		def to_html data
			html = '<ul>'
			data.each do |el|
				html << "<li>#{el}</li>"
			end
			html << '</ul>'

			html
		end
end
