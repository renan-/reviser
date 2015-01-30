#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require 'fileutils'
require 'timeout'
require 'pathname'

require_relative './correction_tools'

class ProjetJava
  include CorrectionTools

  attr_accessor :results_file_dir, :log_file_name, :delay_before_timeout, :build_command

  #############
  # CONSTANTS #
  #############

  @@spread_def = [['Nom binome', :binome],
                  ['Consignes', :consignes],
                  ['Bon nom pgm', :nom_pgm],
                  ['Compilation', :compilation],
                  ['Nbre lignes', :wc_java],
                  ['Indentation'],
                  ['Auteur'],
                  ['Emprunteur'],
                  ['Livre'],
                  ['Test'],
                  ['Commentaire'],
                  ['Note']]

  ##################
  # PUBLIC METHODS #
  ##################

  public

  # Constructor. Set up useful variables.

  def initialize(pgm, projects, spread_filename, timeout = 12)
    # Name of the subdirectory recording results of each project
    @results_file_dir = 'resultats'
    
    # Name of the file containing the results
    @log_file_name = 'rapport.txt'

    # Delay for any execution before timeout (in order to avoid to wait for the end
    # of programs including something like an infinite loop) -> expressed in sec
    @delay_before_timeout = timeout

    # Build command line
    @build_command = 'javac *.java 2>&1'

    # List of the projects (each in a separate directory) to correct
    @projects = projects

    # Set up evaluation environment
    initialize_evaluation(pgm)

    # Correction of projects
    results = projects_analysis

    # Spreadsheet generation
    spreadsheet_generation spread_filename, @@spread_def, results
  end

  #####################
  # PROTECTED METHODS #
  #####################

  protected

  # Analysis of a project

  def project_analysis(base_dir)
    @current_base_dir = base_dir
    project_results = {}
    project_results[:binome] = base_dir

    puts "Je traite #{base_dir}"
    Dir.chdir(base_dir) do
      initialize_project
      preclean_project
      project_results.merge! stats_before_compil
      project_results.merge! compilation
      stats_after_compil
      project_results.merge! correction
      finalize_project
    end

    @current_base_dir = nil
    project_results
  end

  # Analysis of all projects

  def projects_analysis
    @projects.inject([]) do |res, p|
      res << project_analysis(p) if File.directory?(p)
      res
    end
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

  def initialize_evaluation(pgm)
    # Program part
    @expected_pgm = pgm
  end

  # Project initialization

  def initialize_project
    # Create results sub-directory
    FileUtils::rm_rf(@results_file_dir)
    FileUtils::mkdir(@results_file_dir)

    # Create log file
    log_init "#{@results_file_dir}/#{@log_file_name}"
    log_title "Rapport sur le projet de #{@current_base_dir}"

    @java_files = Dir.glob("**/*.java")
    @all_files = Dir.glob("**/*")
    @all_files_top_level = Dir::entries('.') - ['.', '..', @results_file_dir, '.git']
  end

  # Clean the directory of a project in order to really generate it after

  def preclean_project
    # Clean-up non-useful files (if any)
    log_h2 "Nettoyage du répertoire"
    
    # I want to be sure...
    FileUtils::rm_f Dir.glob("*.class")
    FileUtils::rm_f Dir.glob("*~")
  end
  
  # Statistics related to the number of lines

  def stats_wc
    res = stats_wc_l "Java", @java_files, :wc_java
    res
  end

  # Some statistics just before compilation

  def stats_before_compil
    # Readme available?
    include_readme @all_files_top_level

    log_h1 "Statistiques"
    puts "\t...statistiques"

    # Stats on files
    log_puts "\nLe projet est composé des fichiers suivants :"
    @all_files.each { |e| log_puts "\t- #{e}" }
    
    # Stats on number of lines
    results = stats_wc
    results
  end

  # Compilation

  def compilation
    res = {}

    # Conversion to UTF8 and compilation
    convert_files_to_utf8 @java_files
    build_msg = `#{@build_command}`
    log_h1 "Construction du programme"
    log_puts build_msg

    # How many files well compiled?
    class_files = Dir.glob("**/*.class")
    res[:compilation] = "#{class_files.count}/#{@java_files.count}"
    
    res
  end

  # Some statistics after compilation

  def stats_after_compil
    # What files have been generated?
    files_after_compil = Dir::entries('.') - ['.', '..', @results_file_dir, '.git']
    delta_files = files_after_compil - @all_files
    
    log_puts "\nLa compilation a généré les fichiers suivants :"
    delta_files.each { |e| log_puts "\t-#{e}" }
  end

  # Build tests names in an absolute way

  def tests_names_building(tests_dir)
    dir = Pathname.new(tests_dir).realpath
    (Dir::entries(tests_dir) - ['.', '..']).sort!.collect! { |e| dir + e }
  end

  # Launch a command with the generated program

  def launch_command(command, description)
    puts "Je lance #{command}"
    log_h2 "Lancement du test #{description}"

    begin
      Timeout::timeout(@delay_before_timeout) { log_puts `#{command}` }
    rescue Timeout::Error
      # TODO: in this case, a zombie shell still exists. How to remove it?
      # `killall memcheck-x86-li` (for C project, anything for Java ones?)
      puts "*** Test arrêté, exécution trop longue (> #{@delay_before_timeout} sec) ***"
      log_puts "*** Test arrêté, exécution trop longue (> #{@delay_before_timeout} sec) ***"
    end
  end
  
  # Project correction

  def correction
    res = {}
    log_h1 "Trace générée par l'exécution du programme"
    
    # Find source including main method
    
    guess_exec = `grep " main[ (]" *.java`
    
    if guess_exec.lines.count == 1
      exec_name = guess_exec.sub(/^([^.]+)\..*/, '\1').strip
      if exec_name == @expected_pgm
        log_puts "\nL'exécutable s'appelle bien #{@expected_pgm}\n"
        res[:nom_pgm] = true
      else
        log_puts "\n*** L'exécutable ne s'appelle pas #{@expected_pgm}," +
          " mais #{exec_name} ***\n"
        res[:nom_pgm] = false
      end
    else
      exec_name = @expected_pgm
      log_puts "\nProblème (?) pour localiser l'exécutable." +
        " On essaie avec #{@expected_pgm}...\n"
      res[:nom_pgm] = "?"
    end
    
    # Execute 
    launch_command "java #{exec_name}", "unique"
    res
  end

  # Project finalization
  def finalize_project
    log_close
  end
end
