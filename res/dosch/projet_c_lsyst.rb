#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require_relative './ProjetC'

class ProjetCLsyst < ProjetC
  # Heart of project correction

  def correction_with_test(t)
    com = "#{@valgrind} #{@pgm} #{t} 4 #{@results_file_dir}/#{File.basename(t, ".txt") + '.svg'} 600 2>&1"
    launch_command(com, File.basename(t))
  end
end

# ###########
#
# MAIN METHOD
#
# ###########

if ARGV.length < 2
  puts '###############################################################################################'
  puts "Command-line usage: #{$0} <tests directory> <list of projects (i.e. directories)>"
  puts "###############################################################################################\n\n"
else
  ProjetCLsyst.new({ :with_make => 'lsys' }, ARGV[1...ARGV.length], { :with_tests_dir => ARGV[0] }, 30)
end

# Pour corriger
# -------------

# kate */*.[hc] */[Mm]akefile */resultats/rapport.txt &
# google-chrome *.svg &
