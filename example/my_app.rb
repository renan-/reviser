require '../lib/reviser'

require_relative 'my_component'
require_relative 'my_extension'

module MyApp
	include Reviser

	def self.run config_file = 'config.yml'
		#
		# Setup reviser
		#
		Reviser::setup config_file

		Reviser::register :extension => 'MyExtension'
		
		#
		# You can load any built-in component (archiver, organiser, checker, generator)
		# But be aware that they have to be ran in this order, and that
		# organiser takes input from archiver, checker from organiser and generator from checker
		# If you don't respect that, nothing will work.
		# But you can run your component at any step, this won't break the process.
		#
		Reviser::load :component => 'archiver'
		Reviser::load :component => 'organiser', :input_from => 'archiver'

		#
		# Tell reviser not to look for our component
		# in its core ones but to let us include it
		# ourselves instead
		#
		Reviser::load :component => 'my_component', :input_from => 'archiver', :local => true

		Reviser::load :component => 'checker', :input_from => 'organiser'
		Reviser::load :component => 'generator', :input_from => 'checker'

		#
		# Run reviser
		#
		Reviser::run
	end
end