require 'fileutils'

# Class which organizes all directories to simplify project's analysis.
#
# Author::	Yann Prono
class Organiser

	def initialize(directory_working)
		@directory = directory_working
	end

	def run
		entries = Dir.entries(@directory).reject{|entry| entry == "." || entry == ".."}
		entries.each do |entry|
			name = entry.scan(/^[a-zA-Z]+[ ]+[a-zA-Z]+/).first
			name = File.join(@directory, name)
			entry = File.join(@directory, entry)
			FileUtils.mv(entry, name) 
  		end
	end

end