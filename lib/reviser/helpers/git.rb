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

# Class which organizes all directories for use them with git.
# Its another component of the project
#
# @author Romain Ruez
# @author Anthony Cerf
#
module Reviser
	module Helpers
		module Git
			# method which initialize a git repository
			def git_init
				@git = ::Git.init
			end

			# method which allows the user to add something on the repository
			def git_add
				@git.add(:all=>true)
			end

			# method for displaying a message when the repository is configured
			def git_commit
				@git.commit_all('initialization of git repertory')		 
			end

			def git_push
				@git.push
			end

			# method which allows the user to see the differences between two last commits
			# I have to know the current commit and the last but how ?
			# and do a diff between these 2 commits.
			def git_diff

			end
		end
	end
end