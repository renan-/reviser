#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

require 'w3c_validators'

require_relative './correction_tools'

include W3CValidators

module CorrectionToolsWeb
  include CorrectionTools

  # Generic validation of a set of web files

  def w3c_correction(label, validator, files)
    log_h1 "Analyse des fichiers #{label}"
    puts"\t...analyse #{label}"

    total_errors = 0
    kind_of_errors = {}
    
    files.each do |file|
      log_print "\nJe traite le fichier #{file}..."
      puts "\t\t...analyse de #{file}"

      validation_number = 0
      
      begin
        validation_number += 1
        results = validator.validate_file(file)
      rescue Exception => e
        puts "\t\t\t...erreur détectée : " + e.to_s
        retry if validation_number < 3
      end

      if results
        total_errors += results.errors.length
        
        if results.errors.length > 0
          log_puts " des erreurs !"
          results.errors.each do |err|
            log_puts err.to_s
            kind_of_errors[err.message] ||= 0
            kind_of_errors[err.message] += 1
          end
        else
          log_puts " OK !"
        end
      else
          log_puts " fichier ignoré car impossible à corriger"
      end
    end

    log_h2 "Synthèse des erreurs"

    kind_of_errors.each do |key, number|
      log_puts "#{number} #{key}"
    end

    log_puts "\n==> #{total_errors} erreurs trouvées !"
    res = {}
    res[(label.downcase + '_errors').to_sym] = total_errors
    res
  end

  # Validation of a set of HTML files

  def html_correction(html_files)
    w3c_correction('HTML', MarkupValidator.new, html_files)
  end

  # Validation of a set of CSS files

  def css_correction(css_files)
    w3c_correction('CSS', CSSValidator.new, css_files)
  end
end
