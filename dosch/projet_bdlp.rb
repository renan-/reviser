#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require_relative './ProjetJava'

class ProjetBDLP < ProjetJava
end

# ###########
#
# MAIN METHOD
#
# ###########

if ARGV.length < 1
  puts '##################################################################################'
  puts "Command-line usage: #{$0} <list of projects (i.e. directories)>"
  puts "##################################################################################\n\n"
else
  ProjetBDLP.new("Test", ARGV[0...ARGV.length], "yop.xls", 10)
end

# Pour corriger
# -------------

# kate */*.[hc] */[Mm]akefile */resultats/rapport.txt &
# google-chrome *.svg &
