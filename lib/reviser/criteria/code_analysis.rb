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

#
# @author Renan Strauss
#
# Basic criteria
#
module Reviser
	module Criteria
		module CodeAnalysis
			include Helpers::Project

			#
			# @return project's directory contents
			#
			def all_files
				files.join("\r")
			end

			#
			# @return all files matching the 
			# 		  extenstion language list (note that Cfg[:extension] must be an array)
			#
			def src_files
				sources.join("\r")
			end

			#
			# @return the total amount of lines of code
			#
			def lines_count
				count = sources.inject(0) { |sum, f|
					sum + File.open(f).readlines.select { |l| !l.chomp.empty? }.size
				}

				count - comments_count # FIXME
			end

			#
			# @return the number of lines of comments
			#
			def comments_count
				tab_comments = sources.inject([]) { |t, f| t << IO.read(f).scrub.scan(Cfg[:regex_comments]) }
				lines = tab_comments.inject('') { |s, comm| s << find_comments(comm) }.split "\n"

				lines.size
			end

			#
			# Translates a sub-match returned by scan
			# into raw comments string
			#
			def find_comments(comm)
				comm.inject('') { |t, l| t << l.detect { |a| (a != nil) && !a.strip.empty? } + "\n" }
			end
		end
	end
end