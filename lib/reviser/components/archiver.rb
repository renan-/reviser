#
#   Reviser => a semi-automatic tool for student's projects evaluation
#
#   Copyright (C) 2015 Renan Strauss
#   Copyright (C) 2015 Yann Prono
#   Copyright (C) 2015 Romain Ruez
#   Copyright (C) 2015 Anthony Cerf
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'fileutils'
require_relative 'extractors'


module Reviser
	module Components

		# Manages uncompression of archive.
		# Archiver extracts all data in a given compressed file.
		#
		# In case of the University of Lorraine,
		# the archive contains all computing projects, compressed too.
		#
		# If you want to add support of archive format, @see Extractors.
		#
		# @example The simple way to extract a compressed file is :
		#		Archiver.extract(myFile, myDirectory)
		#
		# @author	Yann Prono
		#
		class Archiver < Component

			# methods for each different archive format
			extend Extractors

			# Ignored entries
			$rejected = ['.','..']
			
			# Initializes archive file and the directory of destination.
			def initialize(data)
				super data
				@src = Cfg[:src]
				@destination = Cfg[:dest]
				@results = []
			end


			# Checks if the destination directory exists.
			# else create it.
			# For the moment, if the directory exists // TODO little input to confirm
			# @param destination [String] the destination directory
			#
			def self.destination?(destination)
				unless $rejected.include? File.basename destination
					FileUtils.rm_rf(destination) if Dir.exists? destination
					FileUtils.mkdir_p destination, :mode => 0700
				end
			end
			

			# Extracts the archive into the destination directory.
			# @param file_name 		[String] The name of the archive.
			# @param destination 	[String] The destination directory.
			#
			def self.extract(file_name, destination = '.')
				raise "#{file_name} not found, please check in the current directory." unless File.exist? file_name

				# Get extension of file_name to know which method calls
				ext = File.extname(file_name)
				ext = ext.delete('.')

				# Raise exception if the format is unknown by Archiver
				raise "Unknown compression format '#{ext}'" unless respond_to?(ext)

				# Check if destination exists
				self::destination? destination

				# Run extraction!
				send(ext,file_name, destination)
			end


			# Method which extracts an archive
			# which contains all computing projects.
			#
			# This method extracts,in first time,the archive
			# given in the constructor and after, all extracted files.
			#
			# Use this method in a global usage of Reviser!
			# Options are for the moment :verbose
			#
			def run
				@logger.h1 Logger::INFO,"First extraction - #{@src}"
				# Extract the original archive
				Archiver.extract(@src, @destination)

				@logger.h1 Logger::INFO,'Extraction of sub archives'
				
				# Extract all sub archives
				entries = Dir.entries(@destination) - $rejected
				extracted = 0

				entries.each do |entry|

					ext = File.extname entry
					basename = File.basename entry, ext
					#begin
						file_name = File.join(@destination,File.basename(entry))
						destination = File.join(@destination,basename)

						# Run extraction!
		  				Archiver.extract(file_name, destination)
						extracted += 1

						@logger.h2 Logger::INFO, "extracting #{file_name} to #{destination}"
						@results << basename

					# Delete in all case the archive (useless after this step)
					FileUtils.rm_rf file_name
		  		end
		  		@logger.h1 Logger::INFO, "[#{extracted}/#{entries.size}] projects have been processed"

				@results
			end
		end

	end
end