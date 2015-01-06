require_relative 'lib/component'
require_relative 'lib/reviser'

Component::setup 'config.yml'

# !!! Reviser's run method relies
# on Ruby 1.9+ implementation of
# iteration over hashes, which
# ensures that the hash is iterated
# accordingly to the insertion order
Reviser::load :component => 'archiver'
# Just a dummie component to show what you can do
Reviser::load :component => 'my_component', :inputFrom => 'archiver'
Reviser::load :component => 'organiser', :inputFrom => 'my_component'
# Reviser::load 'checker'
# Reviser::load 'generator', :inputFrom => 'checker'

Reviser::run