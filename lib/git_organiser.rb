# Class which organizes all directories for use them with git.
#
# @author Romain Ruez
# @author Anthony Cerf
#
require 'git'

class GitOrganiser < Component
	def initialize(data=nil)
		super data
		@directory = Cfg[:dest]
	end
	
	def createGitDirectories 
		all(@directory).each do |entry|
		#ajouter fonction pour cree dossier git
		end
	end

end