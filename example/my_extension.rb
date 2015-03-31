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
require 'find'

require_relative '../lib/reviser'

#
# A custom criteria for reviser
#
module MyExtension
	#
	# This helper has the 'sources' methods
	# that allow you to retrieve all sources
	# files (files matching language extension)
	# as well as the 'manufacture' method,
	# needed to adapt results to out format
	#
	include Reviser::Helpers::Project

	#
	# Keep in mind that this method will be run
	# in each project's directory !
	# (that's why we use FileUtils.pwd)
	#
	def project_size
		#
		# That's the way we require gems without worrying
		# of them being installed or not !
		# require_gem is in global scope, and will raise an
		# exception if the given gem is not installed.
		# It will include it otherwise
		#
		unless defined? Filesize
			require_gem 'filesize'
		end

		size_in_bytes = size(FileUtils.pwd)
		results = Filesize.from("#{size_in_bytes} B").pretty
		#
		# The manufacture method excepts
		# a block which must describe the result contents
		# for EACH format.
		# You can also return raw data, then it'll be as it is
		# for all formats.
		#
		manufacture do |format|
			format.html { '<span style="font-weight:bold;">' + results + '</span>' }
			format.csv { results }
			format.xls { results }
		end
	end

	private
		#
		# Returns the size of all the given
		# files (even if there are also dirs)
		# in bytes
		#
		def size(dir)
			bytes = 0
			Find.find(*Dir["#{dir}/**/*"]) { |f| bytes += File.stat(f).size }

			bytes.to_f
		end
end
