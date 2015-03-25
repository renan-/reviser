#
# Here's a custom component
#

require '../lib/reviser'

class MyComponent < Reviser::Component 
	def initialize data
		super data

		@logger.log "Initialized, got data => #{data}"
	end

	def work
		puts 'Hello World, from MyComponent'
		my_resource = Cfg::resource 'example/my_component/data.json'

		JSON.parse(File.read(my_resource)).each do |k, v|
			puts "Got #{k} => #{v}"
		end
	end
end

Reviser::Reviser::setup 'config.yml'
Reviser::Reviser::load 'MyComponent'

Reviser::Reviser::run