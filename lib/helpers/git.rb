# Class which organizes all directories for use them with git.
# Its another component of the project
#
# @author Romain Ruez
# @author Anthony Cerf
#
require 'git'

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