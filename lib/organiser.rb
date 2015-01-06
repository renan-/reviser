require 'fileutils'

# Class which organizes all directories to simplify project's analysis.
#
# Author::	Yann Prono
class Organiser < Component

	# initialize tool
	def initialize(data)
		super data

		@directory = @Cfg[:dest]
	end

	# Rename directories more clearly
	def renameDirectories
		# If the regex doesn't match
		count = 0

		# get all entries of projects folder
		entries = Dir.entries(@directory).reject{|entry| entry == '.' || entry == '..'}
		entries.each do |entry|			

			#apply regex and take first match
			name = entry.scan(/^[a-zA-Z]+[ ]+[a-zA-Z]+/).first
			entry = File.join(@directory, entry)
			if(name != nil)
				name = File.join(@directory, name)
			else
				#Name folder is number if no match
				name = File.join(@directory, "#{count}")
				count+= 1
  			end
  			if(entry != name)
  				FileUtils.mv(entry, name)
  			end
  		end
	end

	# Method which moves project's directories in order to
	# have the same hierarchy for all.
	def structure
		# get all entries of projects folder
		entries = Dir.entries(@directory).reject{|entry| entry == "." || entry == ".."}
		entries.each do |entry|
			path = File.join(@directory, entry)
			level = 0
			directories = Dir.entries(path).reject{|entry| entry == "." || entry == ".."}

			# directory to delete if the project directory is not structured
			rm = directories.first if directories.size == 1
			# Loop to find the core of project
			while(directories.size == 1)
				level += 1
				path = File.join(path, directories.first )
				directories = Dir.entries(path).reject{|entry| entry == "." || entry == ".."}
			end
			# If the core of project is not at the root of directory ...
			if(level >= 1)
				Dir.glob(File.join(path,'*')).each do |file|
					FileUtils.mv(file,File.join(@directory, entry))
				end
				FileUtils.rm_rf(File.join(@directory, entry, rm))
			end

		end
	end


	# Method which run the organiser
	def run
		renameDirectories
		structure
	end

end