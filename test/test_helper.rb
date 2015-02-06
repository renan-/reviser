require 'rubygems'
require 'minitest/autorun'

path = File.join(File.dirname(__FILE__), '..', 'lib','app')
required = Dir[File.join(path,'*.rb')]

required.each do |file|
	require File.expand_path(file)
end