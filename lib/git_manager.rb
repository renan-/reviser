# Class which organizes all directories for use them with git.
# Its another component of the project
#
# @author Romain Ruez
# @author Anthony Cerf
#
require 'git'

class GitManager < Component
	def initialize(data)
		super data
		@g=nil
	end
	
	# La methode run est obligatoire les gars!
	def run
		# On entre dans le dossier de sortie ou sont les projets
		Dir.chdir Cfg[:dest] do
			# On recupere la liste des dossiers (= liste des projets)
			projects = Dir.entries('.') - ['.', '..']
			# Pour chaque projet
			projects.each do |proj|
				# On entre dans le repertoire du projet
				Dir.chdir proj do
					git_init
					git_add
					git_commit
					# Why push ? Maybe you can test if a remote repo is configured?
					# git_push
				end
			end
		end
	end

	# method which initialize a git repository
	def git_init
		@g = Git.init
	end

	# method which allows the user to add something on the repository
	def git_add
		@g.add(:all=>true)
	end

	# method for displaying a message when the repository is configured
	def git_commit
		@g.commit_all('initialization of git repertory')		 
	end

	def git_push
		@g.push
	end

	# method which allows the user to see the differences between two last commits
	# I have to know the current commit and the last but how ?
	# and do a diff between these 2 commits.
	def git_diff

	end
end