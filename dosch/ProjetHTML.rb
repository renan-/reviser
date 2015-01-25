#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require 'fileutils'
require 'pathname'
require 'pp'

require_relative './correction_tools_web'

class ProjetHTML
  include CorrectionToolsWeb

  attr_accessor :results_file_dir, :log_file_name

  #############
  # CONSTANTS #
  #############

  @@spread_def = [['Nom binome', :binome],
                  ['Header', :html_headers],
                  ['# erreurs HTML', :html_errors],
                  ['Nbre lignes HTML', :wc_html],
                  ['Ratio'],
                  ['Validation globale'],
                  ['# erreurs CSS', :css_errors],
                  ['Nbre lignes CSS', :wc_css],
                  ['Validation globale'],
                  ['Explications CSS'],
                  ['Présentation'],
                  ['Conclusion'],
                  ['Richesse'],
                  ['Persistance choix'],
                  ['Espaces noms fichiers', :space_in_filename],
                  ['Extensions htm', :htm_extension],
                  ['index.html', :index_html],
                  ['Thème'],
                  ['[ENT]'],
                  ['Commentaire'],
                  ['Note']]

  ##################
  # PUBLIC METHODS #
  ##################

  public

  # Constructor. Set up useful variables.

  def initialize(projects, spread_filename)
    # Name of the subdirectory recording results of each project
    @results_file_dir = 'resultats'
    
    # Name of the file containing the results
    @log_file_name = 'rapport.txt'

    # List of the projects (each in a separate directory) to correct
    @projects = projects

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
      project_results.merge! init_stats
      project_results.merge! correction
      finalize_project
    end

    # Pourquoi l'instruction suivante ???
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

  def initialize_project
    # Create results sub-directory
    FileUtils::rm_rf(@results_file_dir)
    FileUtils::mkdir(@results_file_dir)

    # Create log file
    log_init "#{@results_file_dir}/#{@log_file_name}"
    log_title "Rapport sur le projet de #{@current_base_dir}"

    @html_files = Dir.glob("**/*.html")
    @css_files = Dir.glob("**/*.css")
    @js_files = Dir.glob("**/*.js")
    @all_files = Dir.glob("**/*")
    @all_files_top_level = Dir::entries('.') - ['.', '..', @results_file_dir, '.git']
  end

  # Statistics related to the number of lines

  def stats_wc
    res = stats_wc_l "HTML", @html_files, :wc_html
    res = stats_wc_l "CSS", @css_files, :wc_css, res
    res = stats_wc_l "JS", @js_files, :wc_js, res
  end

  # Statistics about HTML headers

  def stats_html_headers
    kind_of_headers = []
    
    headers = `head -2 #{@html_files.join(' ')}`
    log_puts headers

    kind_of_headers << 'HTML4' if headers =~ /html 4/i
    kind_of_headers << 'XHTML' if headers =~ /xhtml 1/i
    kind_of_headers << 'HTML5' if headers =~ /html>/i

    kind_of_headers.join('/')
  end
  
  # Some statistics just before compilation

  def init_stats
    res = {}
    
    # Readme available?
    include_readme @all_files_top_level
    
    log_h1 "Statistiques"
    puts "\t...statistiques"

    # Stats on files
    log_puts "\nLe projet est composé des fichiers suivants :"
    @all_files.each { |e| log_puts "\t- #{e}" }

    # Stats on number of lines of different kind of files
    res.merge! stats_wc
    
    # Stats on HTML headers
    log_h2 "Statistiques Headers HTML"
    res[:html_headers] = stats_html_headers

    log_h2 "Autres statistiques"

    # Any file with an '.htm' extension?
    if file_with_ext?(@all_files, '.htm')
      log_puts "\n ==> *** Au moins un fichier à extension .htm ! ***\n"
      res[:htm_extension] = true
    else
      log_puts "\n ==> Aucun fichier à extension .htm\n"
      res[:htm_extension] = false
    end

    # If index.html exists?
    if @html_files.detect {|f| f=~ /index\.html/ }
      log_puts "\n ==> Le fichier index.html existe"
      res[:index_html] = true
    else
      log_puts "\n ==> *** Le fichier index.html n'existe pas ***"
      res[:index_html] = false
    end

    # If there any file including space within its name?
    if space_in_filenames?(@all_files)
      log_puts "\n ==> *** Au moins un fichier contient une espace ! ***\n"
      res[:space_in_filename] = true
    else
      log_puts "\n ==> Pas d'espace dans les noms de fichiers\n"
      res[:space_in_filename] = false
    end

    res
  end

  # Project correction

  def correction
    res = html_correction @html_files
    res.merge! css_correction @css_files
  end

  # Project finalization
  def finalize_project
    log_close
  end
end