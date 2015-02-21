require_relative 'lib/reviser'

Reviser::setup 'config.yml'

# !!! Reviser's run method relies
# on Ruby 1.9+ implementation of
# iteration over hashes, which
# ensures that the hash is iterated
# accordingly to the insertion order
Reviser::load :component => 'archiver'
Reviser::load :component => 'organiser'
#Revisier::load :component => 'git_organiser'
Reviser::load :component => 'checker', :inputFrom => 'organiser'
Reviser::load :component => 'generator', :inputFrom => 'checker'

Reviser::run
