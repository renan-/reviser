require_relative '../test_helper'
require 'fileutils'

#
# Test the Archiver class
# Author:: 	Yann Prono
#
class TestArchiver < Minitest::Test


	def setup
		Cfg::load "#{File.join(File.dirname(__FILE__),'config.yml')}"
		@archiver = Archiver.new
		@file  =@archiver.src
		@dest = @archiver.destination
		@nb_projects = 18
	end

	def teardown 
		FileUtils.rm_rf(@dest)
	end

	# Normal case
	def test_extract
		Archiver.extract(@file, @dest)
		entries = Dir.entries(@dest).reject{|entry| entry == '.' || entry == '..'}
		assert(entries.size >= 1, 'the extraction should extract some entries')
	end

	# File not found
	def test_extract_no_file
		assert_raises Errno::ENOENT do
			Archiver.extract('coucou.zip', @dest)
		end
	end

	# Test if the default directory works
	def test_extract_default_dest
		# Get all entries before running
		original = Dir.entries('.').reject{|entry| entry == '.' || entry == '..'}
		# Let's do it 
		Archiver.extract @file
		# Get all entries after running
		after = Dir.entries('.').reject{|entry| entry == '.' || entry == '..'}
		assert_equal((after - original).size, @nb_projects, 'the extraction should extract all entries in the current directory')
		FileUtils.rm(after-original)
	end

	# Test if the extraction could be in subfolders
	def test_extract_subfolders
		folders = 'projects/Students/'
		
		Archiver.extract(@file, folders)
		entries = Dir.entries(folders).reject{|entry| entry == '.' || entry == '..'}		
		assert_equal(entries.size, @nb_projects, "the extraction should extract all entries in subfodlers #{folders}")
		FileUtils.rm_rf folders
	end

	# If the archive is a unknown format
	# Should raise a exception
	def test_extract_unknown_format
		assert_raises NoMethodError do
			Archiver.extract('format.ar')
		end
	end

	
	def test_run
		@archiver.run
		entries = Dir.entries(@dest).reject{|entry| entry == '.' || entry == '..'}
		assert_equal(@nb_projects, entries.size, "the directory was expected to contain #{@nb_projects} directories.")
	end

	# Test destination method
	# the folder doesn't exist
	def test_destination_mkdir		
		Archiver.destination?(@dest)
		assert(Dir.exists?(@dest), "The #{@dest} directory should exist")
	end

	# Test destination method
	# The folder is firstly deleted and created
	def test_destination_rm
		FileUtils.mkdir(@dest)
		FileUtils.touch File.join(@dest, 'README.md')
		Archiver.destination?(@dest)
		assert(Dir.exists?(@dest), "The #{@dest} directory should exist")
		assert_equal(Dir.glob(File.join(@dest,'*')).size,0, "The #{@dest} directory shouldn't contain files")
	end

end