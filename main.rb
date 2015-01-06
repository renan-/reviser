require_relative 'lib/component'
require_relative 'lib/reviser'

Component::setup 'config.yml'

Reviser::load 'archiver'
Reviser::load 'organiser'
# Reviser::load 'checker'
# Reviser::load 'generator', :inputFrom => 'checker'

Reviser::run