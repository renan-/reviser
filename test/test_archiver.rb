require_relative "../lib/archiver"
require_relative "../lib/component"
require_relative "../lib/reviser"
require "test/unit"

#
# Test the Archiver class
# Author:: 	Yann Prono
#
class TestArchiver < Test::Unit::TestCase


	def setup
		Component::setup 'config.yml'
		@archiver = Archiver.new(nil)
		@nb_projects = 15
	end

	def teardown 
	end

	def test_run
		@archiver.run
		entries = Dir.entries(@archiver.destination).reject{|entry| entry == '.' || entry == '..'}
		assert(Dir.exists?(@archiver.destination), "The directory #{@archiver.destination} should exist")
		assert_equal(@nb_projects, entries.size, "the directory was expected to contain #{@nb_projects} directories.")
	end

end