²require_relative "../../lib/archiver"
require_relative "../../lib/component"
require_relative "../../lib/reviser"
require "test/unit"
require "fileutils"

#
# Test the Archiver class
# Author:: 	Yann Prono
#
class TestArchiver < Test::Unit::TestCase


	def setup
		Component::setup 'config.yml'
		@archiver = Archiver.new(nil)
		@file = @archiver.src
		@dest = @archiver.destination
		@nb_projects = 15
	end

	def teardown 
		FileUtils.rm_rf(@dest)
	end

	# Verify constructor
	def test_initialize
		assert(Dir.exists?(@dest), "The directory #{@dest} should exist")
	end

	# Normal case
	def test_extract
		Archiver.extract(@file, @dest)
		entries = Dir.entries(@dest).reject{|entry| entry == '.' || entry == '..'}
		assert(entries.size >= 1, "the extraction should extract some entries")
	end

	# File not found
	# TODO find how to test exception
	def test_extract_no_file
		raise = false
		Archiver.extract("coucou.zip", @dest)
		assert_raise Errno::ENOENT do
		end
	end

	
	def test_run
		@archiver.run
		entries = Dir.entries(@dest).reject{|entry| entry == '.' || entry == '..'}
		assert_equal(@nb_projects, entries.size, "the directory was expected to contain #{@nb_projects} directories.")
		end

end