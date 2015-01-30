#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

# require 'fileutils'
# require 'timeout'
# require 'pathname'
require 'spreadsheet'
require 'pp'

module CorrectionTools

  #
  # LOG MANAGMENT
  #
  
  # Open the log file in writing mode
  def log_init(filename)
    @log_file = File::open(filename, 'w')
  end

  # Writing methods for the log file
  def log_puts(message)
    @log_file.puts(message)
  end

  def log_title(message)
    @log_file.puts("\n" + ("=" * message.length))
    @log_file.puts(message)
    @log_file.puts(("=" * message.length) + "\n")
  end

  def log_header(message, subchar)
    @log_file.puts("\n" + message)
    @log_file.puts((subchar * message.length) + "\n")
  end

  def log_h1(message)
    log_header("\n" + message, '=')
  end

  def log_h2(message)
    log_header(message, '-')
  end

  def log_print(message)
    @log_file.print(message)
  end

  def log_stdout_puts(message)
    log_puts(message)
    puts message
  end

  def log_stdout_print(message)
    log_print(message)
    print message
  end

  # Close the log file
  def log_close
    @log_file.close
  end

  #
  # TOOLS
  #

  # Stats using wc -l
  def stats_wc_l(label, files, key, res = {})
    log_h2 "Statistiques #{label}"
    msg, number = wc_l files
    log_puts msg
    res[key] = number

    res
  end

  
  # Number of lines using wc -l
  def wc_l(files)
    if files.empty?
      return 'Aucun fichier trouvé', 0
    else
      if files.count > 500
        return "Trop de fichiers (#{files.count})", 0
      else
        wc_out = `wc -l #{files.collect{|f| "'#{f}'"}.join(' ')}`
        return wc_out, wc_out.gsub(/.*\s(\d+) total/m, '\1').strip.to_i
      end
    end
  end

  # Number of lines of a single file
  def wc_l_single_file(file)
    `wc -l #{file}`.gsub(/^(\d+) .+$/, '\1').to_i
  end

  # Include a readme.txt file (if any)
  def include_readme(files)
    if readme_key = files.index{ |f| f=~ /readme\.txt/i }
      log_h2 "Le fichier README existe !"
      log_puts IO.read(files[readme_key])
    end
  end
  
  # At least one space in filenames?
  def space_in_filenames?(filenames)
    filenames.detect { |name| name.include?(' ') }
  end

  # Existence of at least one file with a particular extension
  # ('!!' allows to convert anything into boolean)

  def file_with_ext?(files, ext)
    !!files.detect { |f| File.extname(f) == ext }
  end
  
  # Convert a list of files into UTF8
  def convert_files_to_utf8(list_of_files)
    list_of_files.each do |f|
      tmp_file_name = "tmp.iconv.#{f}"
      source_lines = wc_l_single_file f
      
      # First, try to automatically convert the file
      `iconv --to-code utf8 #{f} > #{tmp_file_name} 2> /dev/null`
      if source_lines == wc_l_single_file(tmp_file_name)
        FileUtils::mv(tmp_file_name, f)
      else
        
        # If it does not work, try to force original encoding
        FileUtils::rm_f tmp_file_name
        `iconv --from-code=ISO-8859-1 --to-code utf8 #{f} > #{tmp_file_name} 2> /dev/null`
        if source_lines == wc_l_single_file(tmp_file_name)
          FileUtils::mv(tmp_file_name, f)
        else
          
          # No conversion work, we leave the original file unchanged
          FileUtils::rm_f tmp_file_name
        end
      end
    end
  end

#
  # SPREADSHEET MANAGMENT
  #

  # TODO/Ideas
  #   - Add an expected value for some entries and change the background
  #     whenever this value is not met
  #   - Refactoring using rubyXL (to allow in particular inclusion of formulas?
  
  # Main method about spreadsheet generation

  def spreadsheet_generation(filename, spread_def, results)
    spread_init spread_headers spread_def
    results.each { |r| spread_add_line spread_line_formatting spread_def, r }
    spread_finalize filename
  end

  # Spreadsheet headers extraction

  def spread_headers(spread_def)
    spread_def.inject([]) { |res, e| res << e[0] }
  end

  # Spreadsheet initialization

  def spread_init(headers)
    # Create spreadsheet
    @spread_res = Spreadsheet::Workbook.new

    # Create create_worksheet
    @spread_res.create_worksheet :name => "Résultats"

    # Insert headers
    @spread_res.worksheet(0).insert_row(0, headers)
    format = Spreadsheet::Format.new
    font = Spreadsheet::Font.new('', :size => 12, :weight => :bold)
    format.font = font
    @spread_res.worksheet(0).last_row.default_format = format
  end

  # Format a line of results with respect to the expected sequence of results

  def spread_line_formatting(spread_def, line)
    spread_def.inject([]) { |res, attr| res << ((attr[1]) ? line[attr[1]] : '') }
  end

  # Add a line (a student) into a Spreadsheet

  def spread_add_line(infos)
    new_row_index = @spread_res.worksheet(0).last_row_index + 1
    @spread_res.worksheet(0).insert_row(new_row_index, infos)

    # format = Spreadsheet::Format.new :color=> :blue, :pattern_fg_color => :red, :pattern => 1,:size => 18
    # format = Spreadsheet::Format.new :pattern_fg_color => :yellow, :pattern => 1
    # @spread_res.worksheet(0)[3,3] = '=A1'
    # @spread_res.worksheet(0).row(3).set_format(3, format)
  end
  
  # Spreadsheet finalization

  def spread_finalize(filename)
    @spread_res.write filename
  end
end
