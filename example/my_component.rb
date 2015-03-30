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
require 'json'
require '../lib/reviser'

#
# Let's build a custom component !
# It just parses an example JSON file and prints it
#
class MyComponent < Reviser::Component 
	#
	# Don't forget to call super !
	#
	# If you told Reviser to take input from another
	# component, @data will contains it
	#
	def initialize data
		super data

		@logger.info { "Initialized, got data => #{data}" }
	end

	#
	# All components must implement a run method
	#
	def run
		puts 'Hello World from MyComponent, got @data = ' + @data.to_s

		my_resource = resource 'example/data.json'
		JSON.parse(File.read(my_resource)).each do |k, v|
			puts "Got #{k} => #{v}"
		end
	end
end