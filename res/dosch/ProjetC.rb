#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require 'fileutils'
require 'timeout'
require 'pathname'

class ProjetC
  attr_accessor :results_file_dir, :log_file_name, :valgrind, :delay_before_timeout, :build_command

  ##################
  # PUBLIC METHODS #
  ##################

  public

  # Constructor. Set up useful variables.

  def initialize(pgm, projects, evaluation, timeout = 12)
    # Name of the subdirectory recording results of each project
    @results_file_dir = 'resultats'
    
    # Name of the file containing the results
    @log_file_name = 'rapport.txt'

    # How to launch Valgrind?
    @valgrind = 'valgrind --leak-check=full --track-origins=yes --show-reachable=yes'

    # Delay for any execution before timeout (in order to avoid to wait for the end
    # of programs including something like an infinite loop) -> expressed in sec
    @delay_before_timeout = timeout

    # Build command line (in case no makefile is available)
    @build_command = 'gcc -ansi -pedantic -Wall -g'

    # List of the projects (each in a separate directory) to correct
    @projects = projects

    # Set up evaluation environment
    initialize_evaluation(pgm, evaluation)

    # Correction of projects
    projects_analysis
  end

  #####################
  # PROTECTED METHODS #
  #####################

  protected

  # Analysis of a project

  def project_analysis(base_dir)
    @current_base_dir = base_dir

    puts "Je traite #{base_dir}"
    Dir.chdir(base_dir) do
      initialize_project
      preclean_project
      before_files = stats_before_compil
      compilation
      stats_after_compil(before_files)
      correction
      finalize_project
    end

    @current_base_dir = nil
  end

  # Analysis of all projects

  def projects_analysis
    @projects.each { |p| project_analysis(p) if File.directory?(p) }
  end

  # Evaluation is led by tests files included in a directory
  # (whose the name is the evaluation parameter of the constructor)

  def evaluation_with_tests_directory
    @tests_names = tests_names_building(@evaluation_value)
  end

  # Evaluation is led by a single test file
  # (whose the name is the evaluation parameter of the constructor)

  def evaluation_with_single_test
    @test_name = @evaluation_value
  end

  # Evaluation environment initialization

  def initialize_evaluation(pgm, evaluation)
    # Program part
    @pgm = pgm.values[0]
    pgm_key = pgm.keys[0]

    case pgm_key
    when :with_make
      @make = true
    when :without_make
      @make = false
    else
      raise "Type de construction non reconnu"
    end

    # Evaluation part
    @evaluation_key = evaluation.keys[0]
    @evaluation_value = evaluation.values[0]

    case @evaluation_key
    when :with_tests_dir
      evaluation_with_tests_directory
    when :with_test
      evaluation_with_single_test
    else
      raise "Type d'évaluation non reconnu"
    end
  end

  # Project initialization

  def initialize_project
    # Create results sub-directory
    FileUtils::rm_rf(@results_file_dir)
    FileUtils::mkdir(@results_file_dir)

    # Create log file
    @log_file = File::open("#{@results_file_dir}/#{@log_file_name}", 'w')

    @log_file.puts "========================================================="
    @log_file.puts "Rapport sur le projet de #{@current_base_dir}"
    @log_file.puts "=========================================================\n"
  end

  # Clean the directory of a project in order to really generate it after

  def preclean_project
    # Clean-up non-useful files (if any)
    clean_msg = `make clean 2>&1`
    @log_file.puts "\nNettoyage du répertoire :\n\n#{clean_msg}"
    
    # I want to be sure...
    FileUtils::rm_f Dir.glob("*.o")
    FileUtils::rm_f Dir.glob("*~")
  end
  
  # Some statistics just before compilation

  def stats_before_compil
    # Readme available?
    if File.exists?('readme.txt')
      @log_file.puts "\nLe fichier README existe !\n"
      @log_file.puts IO.read('readme.txt')
    end

    # Stats on files
    files_before_compil = Dir::entries('.') - ['.', '..', @results_file_dir]
    @log_file.puts "\nLe projet est composé des fichiers suivants :"
    files_before_compil.each { |e| @log_file.puts "\t-#{e}" }

    # Stats on number of lines
    nb_lines = `wc -l *.h *.c`
    @log_file.puts "\nStatistiques :\n #{nb_lines}"

    files_before_compil
  end

  # Compilation with a valid makefile

  def compilation_with_makefile
    # Build the program
    depend_msg = `make depend 2>&1`
    build_msg = `make 2>&1`
    
    @log_file.puts "\nConstruction des dépendances :\n\n#{depend_msg}"
    @log_file.puts "\nConstruction du programme :\n\n#{build_msg}"
  end

  # Compilation without any makefile

  def compilation_without_makefile
    # Build the program
    build_msg = `#{@build_command} *.c -o #{@pgm}`
    @log_file.puts "\nConstruction du programme :\n\n#{build_msg}"
  end

  # Compilation

  def compilation
    if @make
      compilation_with_makefile
    else
      compilation_without_makefile
    end
  end

  # Some statistics after compilation

  def stats_after_compil(files_before_compil)
    # What files have been generated?
    files_after_compil = Dir::entries('.') - ['.', '..', @results_file_dir]
    delta_files = files_after_compil - files_before_compil
    
    @log_file.puts "\nLa compilation a généré les fichiers suivants :"
    delta_files.each { |e| @log_file.puts "\t-#{e}" }
  end

  # Build tests names in an absolute way

  def tests_names_building(tests_dir)
    dir = Pathname.new(tests_dir).realpath
    (Dir::entries(tests_dir) - ['.', '..']).sort!.collect! { |e| dir + e }
  end

  # Launch a command with the generated program

  def launch_command(command, description)
    puts "Je lance #{command}"
    @log_file.puts "\n============================================"
    @log_file.puts "Lancement du test #{description}"
    @log_file.puts '============================================'

    begin
      Timeout::timeout(@delay_before_timeout) { @log_file.puts `#{command}` }
    rescue Timeout::Error
      # TODO: in this case, a zombie shell still exists. How to remove it?
      `killall memcheck-x86-li`
      puts "*** Test arrêté, exécution trop longue (> #{@delay_before_timeout} sec) ***"
      @log_file.puts "*** Test arrêté, exécution trop longue (> #{@delay_before_timeout} sec) ***"
    end
  end
  
  # Correction according to a test
  # To be overrided to change way of correction

  def correction_with_test(t)
  end

  # Correction of tests of a directory

  def correction_with_tests_directory
    @tests_names.each do |t|
      correction_with_test(t)
    end
  end

  # Heart of project correction

  def do_correction
    case @evaluation_key
    when :with_tests_dir
      correction_with_tests_directory  
    when :with_test
      correction_with_test(@test_name)
    end
  end

  # Project correction

  def correction
    if File.exists?(@pgm)
      @log_file.puts "\nTrace générée par l'exécution du programme"
      do_correction
    else
      puts "L'exécutable #{@pgm} n'a pas été généré, fin de la correction..."
      @log_file.puts "\nL'exécutable #{@pgm} n'a pas été généré, fin de la correction...\n"
    end
  end

  # Project finalization
  def finalize_project
    @log_file.close
  end
end
