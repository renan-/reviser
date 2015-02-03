require_relative '../test_helper'

#
# Test of organiser class
# @author Yann Prono
#
class TestOrganiser < Minitest::Test

	$rejected = ['.','..','__MACOSX']

	def setup
		Component::setup 'config.yml'

		@archiver = Archiver.new(nil)
		@dest = @archiver.destination
		FileUtils.rm_rf(@dest)
		@archiver.run
		@organiser = Organiser.new(nil)
	end

	# Check if projects are not deleted
	# display projects which are not renamed
	def test_renameDirectories
		old = Dir.entries(@dest)- $rejected
		nb = old.size
		@organiser.renameDirectories
		entries = Dir.entries(@dest)- ['.','..']
		assert_equal(nb, entries.size,'projects should not be deleted')
		puts "#{(old & entries).size} projects could not been renamed"
		(old & entries).each do |entry| puts "	- #{entry}" end

		FileUtils.rm_rf(@dest)
	end

	# Visual test
	def test_structure
		@organiser.structure
		entries = Dir.entries(@dest)- $rejected
		errors = Array.new
		entries.each do |entry|
			tmp = Dir.entries(File.join(@dest, entry)) - $rejected
			errors << entry if tmp.size == 1
		end

		assert_equal(0, errors.size,"Some directories are not structured #{errors}")

	end


end