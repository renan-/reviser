require_relative "../lib/archiver"
require_relative "../lib/component"
require_relative "../lib/reviser"
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
		@nb_projects = 18
	end

	def teardown 
		FileUtils.rm_rf(@dest)
	end


	# Case when the directory doesn't exist
	def test_destination?()
		dir = "Jim Weirich"
		Archiver::destination?(dir)
		assert(Dir.exists?(dir), "The directory #{dir} should exist")
		FileUtils.rm_rf dir
	end

	# Case when the directory already exists
	def test_destination_exist()
		dir = "Jim Weirich"
		FileUtils.mkdir dir, :mode => 0700
		filepath = File.join(dir,'testFile')
		FileUtils.touch filepath
		Archiver::destination?(dir)
		assert(Dir.exists?(dir), "The directory #{dir} should exist")
		assert(!File.exists?(filepath), "The directory shouldn't contain any files")
		FileUtils.rm_rf dir
	end

	# Normal case
	def test_extract
		Archiver.extract(@file, @dest)
		assert(entries.size >= 1, "the extraction should extract some entries")
	end

	# File not found
	def test_extract_no_file		
		assert_raise(Errno::ENOENT) {Archiver.extract("coucou.zip", @dest)}
	end

	
	def test_run
		@archiver.run
		entries = Dir.entries(@dest).reject{|entry| entry == '.' || entry == '..'}
		assert_equal(@nb_projects, entries.size, "the directory was expected to contain #{@nb_projects} directories.")
	end

end