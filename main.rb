require_relative 'lib/component'

def run(config_file)
	Component::setup config_file

	Component::load 'archiver'

	Component::run
end

run 'config.yml'