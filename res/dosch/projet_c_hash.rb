#!/usr/bin/ruby -w

require 'fileutils'

# Name of the subdirectory recording results of each project
$results = 'resultats'

#
# PROCESS THE PROJECTS, AND CREATE A SUB-DIRECTORY IN EACH ONE
# CONTAINING ITS RESULTS
#

(Dir::entries('.') - ['.', '..']).each do |d|
  Dir.chdir(d) do 
    # Create results sub-directory
    FileUtils::rm_rf($results)
    FileUtils::mkdir($results)
    
    # Clean-up non-useful files (if any)
    clean_msg = `make clean 2>&1`
    # I want to be sure...
    FileUtils::rm_f Dir.glob("*.o")
    FileUtils::rm_f Dir.glob("*~")
    
    # Stats
    nb_lines = `wc -l *.h *.c`
    
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

      if File.exists?('README.txt')
        f.puts "\nREADME\n\n"
        f.puts IO.read('README.txt')
      else
        f.puts "\nPas de README..."
      end

      if File.exists?('tests.txt')
        f.puts "\nTests :\n"
        f.puts IO.read('tests.txt')
      else
        f.puts "\nPas de tests.txt..."
      end

      # Build the program
      build_msg = `make 2>&1`

      f.puts "\nNettoyage du répertoire :\n\n#{clean_msg}"

      f.puts "\nConstruction du programme :\n\n#{build_msg}"
      
      # What files have been generated?
      files_after_compil = Dir::entries('.') - ['.', '..', $results]
      delta_files = files_after_compil - files_before_compil

      f.puts "\nLa compilation a généré les fichiers suivants :"

      delta_files.each do |e|
        f.puts "\t-#{e}"
      end
    end
  end
end

