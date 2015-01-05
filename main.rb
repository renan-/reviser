require_relative 'lib/component'

Component::setup 'config.yml'
Component::load  'archiver'

Component::run