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
require '../lib/reviser'


#
# A custom criteria for reviser
#
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
