#
# Here's a custom component
#

require 'json'
require '../lib/reviser'

class MyComponent < Reviser::Component 
	def initialize data
		super data

		@logger.info { "Initialized, got data => #{data}" }
	end

	def run
		puts 'Hello World, from MyComponent'
		my_resource = resource 'example/data.json'

		JSON.parse(File.read(my_resource)).each do |k, v|
			puts "Got #{k} => #{v}"
		end
	end
end

module MyApp
	include Reviser

	def self.run config_file = '../config.yml'
		Reviser::setup config_file
		
		#
		# Tell reviser not to look for our component
		# in its core ones but to let us include it
		# ourselves
		#
		Reviser::load :component => 'my_component', :local => true
		Reviser::run
	end
end

MyApp.run