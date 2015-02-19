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
					# On initialise un depot git
					git_init
					# ...
				end
			end
		end
	end

	# En ruby la methode doit s'appeler create_git_directories
	# (on n'est pas en Java tout degueulasse !!)
	# Je la renomme git_init, c'est plus dans l'esprit de ruby
	# (et surtout dans l'esprit du projet)
	# Et la methode all n'est pas appropriee du tout, il faut lire la doc!
	def git_init
		# Il faut s'inspirer des autres composants
		# J'ai restructure le votre pour que vous n'ayez
		# que a vous concentrer sur ce qu'il faut faire pour 1
		# projet, sans se soucier de ou vous etes
		# Cette methode sera appellee dans le repertoire du
		# projet pour lequel il faut initialiser un depot git
	end

end