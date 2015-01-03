require 'fileutils'

# Class which organizes all directories to simplify project's analysis.
#
# Author::	Yann Prono
class Organiser

	# initialize tool
	def initialize(directory_working)
		@directory = directory_working
	end

	# Method which renames project's folder.
	def run
		# If the regex doesn"t match
		count = 0;
		
		# get all entries of projects folder
		entries = Dir.entries(@directory).reject{|entry| entry == "." || entry == ".."}
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
  			FileUtils.mv(entry, name)
  		end
	end

end