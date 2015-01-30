#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require_relative './ProjetPHP'


# ##################################
#
# CORRECTION CLASS FOR WIKI PROJECTS
#
# ##################################

class ProjetPHPRacurl < ProjetPHP

  #############
  # CONSTANTS #
  #############

  @@spread_def = [['Nom binome', :binome],
                  ['Header', :html_headers],
                  ['# erreurs CSS', :css_errors],
                  ['Nbre lignes', :wc_css],
                  ['Validation globale'],
                  ['Nbre lignes JS', :wc_js],
                  ['Nbre lignes PHP', :wc_php],
                  ['index.php', :index_php],
                  ['Espaces noms fichiers', :space_in_filename],
                  ['Création / connexion utilisateur'],
                  ['Réduction URL'],
                  ['Accès URL réduite'],
                  ['Historique URL membre'],
                  ['Interdiction boucle URL'],
                  ['Gestion ressources membre'],
                  ['Administrateur'],
                  ['Statistiques'],
                  ['Cookies'],
                  ['Sécurité'],
                  ['Apparence'],
                  ['Convivialité'],
                  ['Framework'],
                  ['Commentaire'],
                  ['Note']]

  # Return spreadsheet headers
  def spreadsheet_headers
    @@spread_def
  end
end


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
  ProjetPHPRacurl.new(ARGV[0..(ARGV.length - 1)], 'yop.xls')
end

# Pour corriger
# -------------

# Validation W3 HTML
# Validation feuilles de styles
# Rapport
# Intérêt feuille de styles
# Divers

