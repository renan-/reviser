#
# Author:: Renan Strauss
#
# TODO
# Organise the checker around modules for
# each group of criterias (code, compilation, execution, and so on)
#

class Checker < Component
	def initialize(data)
		super data

		@results = {}
	end

	def run
		# We'll work in the dest directory
		Dir.chdir @Cfg[:dest] do
			# The data we got from Organiser is a tab
			# which contains all the project folders.
			@data.each do |proj|
				Dir.chdir proj do
					files = Dir.glob('*').select { |f| (File.file?(f)) }
					src_files = files.select { |f| @Cfg[:extension].include? File.extname(f) }

					@results[proj] = {
						:fichiers => files.join("\r"),
						:fichiers_sources => src_files.join("\r"),
						:nombre_total_de_lignes_de_code => files.inject(0) { |sum, f|
							sum + File.open(f).readlines.select { |l| 
								(!l.chomp.empty?) && (l.scrub !~ @Cfg[:regex_comments])  
							}.size 
						},
						:nombre_de_commentaires => 	src_files.inject([]) { |tab, f|
								tab << IO.read(f).scrub.scan(@Cfg[:regex_comments])
							}.inject("") { |s, comm|
								s << comm.inject("") { |t, l|
									t << (l.size > 3 && l[3] + "\n") || ""
								}
							}.split("\n").size
					}
				end
			end
		end

		return @results
	end
end