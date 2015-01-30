#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require 'fileutils'

# Name of the subdirectory recording results of each project
$results = 'resultats'

# Name of the subdirectory recording results of documentation
$doc = 'doc'

# Name of the file containing the results
$results_file = 'trace.txt'

# Expected name of resulting executable (Java main class...)
$expected_exec_name = 'Principale'

#
# PROCESS THE PROJECTS, AND CREATE A SUB-DIRECTORY IN EACH ONE
# CONTAINING ITS RESULTS
#

(Dir::entries('.') - ['.', '..']).each do |d|
  Dir.chdir(d) do 
    # Information on processing
    puts "Processing #{d}..."

    # Create results sub-directory
    FileUtils::rm_rf($results)
    FileUtils::mkdir($results)
    
    # Clean-up non-useful files (if any)
    # I want to be sure...
    FileUtils::rm_f Dir.glob("*.class")
    FileUtils::rm_f Dir.glob("*~")
    
    # Stats
    nb_lines = `wc -l *.java`
    
    # Build report
    File::open("#{$results}/rapport.txt", 'w') do |f|
      f.puts "========================================================="
      f.puts "Rapport sur le projet de #{d}"
      f.puts "=========================================================\n"

      files_before_compil = Dir::entries('.') - ['.', '..', $results]
      f.puts "\nLe projet est composé des fichiers suivants :"

      files_before_compil.each do |e|
        f.puts "\t-#{e}"
      end

      f.puts "\nStatistiques :\n #{nb_lines}"

      # Is it possible to guess character encoding?
      raw_file = `file *.java`
      is_iso = raw_file.include? 'ISO-8859'
      is_utf = raw_file.include? 'UTF-8'

      # Build the program
      if is_utf
        build_msg = `javac *.java 2>&1`
      else
        build_msg = `javac -encoding iso-8859-1 *.java 2>&1`
      end
      
      #f.puts "\nNettoyage du répertoire :\n\n#{clean_msg}"
      
      f.puts "\nConstruction du programme :\n\n#{build_msg}"
      
      # What files have been generated?
      files_after_compil = Dir::entries('.') - ['.', '..', $results]
      delta_files = files_after_compil - files_before_compil

      f.puts "\nLa compilation a généré les fichiers suivants :"

      delta_files.each do |e|
        f.puts "\t-#{e}"
      end

      if File.exists?('readme.txt')
        f.puts "\nLe fichier README existe !\n"
        f.puts IO.read('readme.txt')
      end
      
      f.puts "\nTrace générée par l'exécution du programme"

      # Find source including main method

      guess_exec = `grep " main[ (]" *.java`

      if guess_exec.lines.count == 1
        exec_name = guess_exec.sub(/^([^.]+)\..*/, '\1').strip
        if exec_name == $expected_exec_name
          f.puts "\nL'exécutable s'appelle bien #{$expected_exec_name}\n"
        else
          f.puts "\n*** L'exécutable ne s'appelle pas #{$expected_exec_name}," +
            " mais #{exec_name} ***\n"
        end
      else
        exec_name = $expected_exec_name
        f.puts "\nProblème pour localiser l'exécutable." +
          " On essaie avec #{$expected_exec_name}...\n"
      end

      # Execute 
      `java #{exec_name} > sortie#{d}.txt`

      # Documentation
      FileUtils::rm_rf($doc)
      FileUtils::mkdir($doc)

      if is_utf
        `javadoc -private -d #{$doc} *.java`
      else
        `javadoc -private -encoding iso-8859-1 -d #{$doc} *.java`
      end
    end
  end
end

# Pour explorer les différents TP par la suite :
# kate *.java resultats/rapport.txt& ; kdiff3 sortie*.txt ../../sortie.txt& ; kdiff3 sortie*.txt ../../sortie-utf.txt& ; konqueror doc/index.html&
