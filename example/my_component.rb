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

#
# Then we run it
#
module MyApp
	include Reviser

	def self.run config_file = '../config.yml'
		#
		# Setup reviser
		#
		Reviser::setup config_file
		
		#
		# You can load any built-in component (archiver, organiser, checker, generator)
		# But be aware that they have to be ran in this order, and that
		# organiser takes input from archiver, checker from organiser and generator from checker
		# If you don't respect that, nothing will work.
		# But you can run your component at any step, this won't break the process.
		#
		# Reviser::load :component => 'archiver'
		# Reviser::load :component => 'organiser', :input_from => 'archiver'

		#
		# Tell reviser not to look for our component
		# in its core ones but to let us include it
		# ourselves instead
		#
		Reviser::load :component => 'my_component', :local => true #, :input_from => 'archiver'

		# Reviser::load :component => 'checker', :input_from => 'organiser'
		# Reviser::load :component => 'generator', :input_from => 'checker'

		#
		# Run reviser
		#
		Reviser::run
	end
end

MyApp::run