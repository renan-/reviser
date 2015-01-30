#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require_relative './ProjetHTML'


# ###########
#
# MAIN METHOD
#
# ###########

if ARGV.length < 1
  puts '#####################################################################################'
  puts "Command-line usage: #{$0} <list of projects (i.e. directories)>"
  puts "######################################################################################\n\n"
else
  ProjetHTML.new(ARGV[0..(ARGV.length - 1)], 'yop.xls')
end

# Pour corriger
# -------------

# Validation W3 HTML
# Validation feuilles de styles
# Rapport
# Intérêt feuille de styles
# Divers

