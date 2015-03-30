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
# This class represents an analysis result
# It allows us to easily output well-formatted results for certain output formats
# (eg HTML)
#
# @author Renan Strauss
#
module Reviser
	class Result
		#
		# In case no call to manufacture was made,
		# Checker will create a result with the same
		# valeu for all formats
		#
		def initialize data = nil
			if data != nil
				Cfg[:out_format].each do |format|
					instance_variable_set("@#{format}".to_sym, data)
				end
			end
		end

		#
		# Does the magic ;-)
		# When the user calls a method whose name is a valid format,
		# we associate it with the given block value if a block is given,
		# else we return the stored value
		#
		def method_missing m, *args, &block
			raise NoMethodError, "Unknown format #{m}" unless Cfg::OUT_FORMATS.include?(m)

			format = "@#{m}".to_sym

			block_given? && instance_variable_set(format, block[]) || instance_variable_get(format)
		end
	end
end