# Class which organizes all directories for use them with git.
#
# @author Romain Ruez
# @author Anthony Cerf
#
require 'git'

class GitOrganiser < Component
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

	def git_init
		@g = Git.init
	end
	
	def git_add
		@g.add(:all=>true)
	end
	
	def git_commit
		@g.commit_all('initialization of git repertory')		 
	end

	def git_push
		@g.push
	end
end