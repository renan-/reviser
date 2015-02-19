# Class which organizes all directories for use them with git.
#
# @author Romain Ruez
# @author Anthony Cerf
#
require 'git'

class GitOrganiser < Component
	def initialize(data)
		super data
	end
	
	def createGitDirectories 
		all(Cfg[:dest]).each do |entry|
			#ajouter fonction pour cree dossier git
		end
	end

end