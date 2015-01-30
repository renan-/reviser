#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


#
# TODO
#
# - Ajouter la possibilité de parser un ancien fichier CSV, voire XLS,
#   afin de récupérer les en-têtes et les réinjecter dans
#   le futur fichier ?
# - Réfléchir à la gestion d'acronymes permettant de qualifier
#   les erreurs rencontrées sur les projets des étudiants ?
# - Possibilité d'exécuter le script pour une étape donnée
#   (récupération, tri, etc.) + affichage en menu des étapes
#   possibles
# - Gérer des tests unitaires (pour se faire la main) ?
#

require 'fileutils'

# ###############################################
#
# CONSTANTS DEFINITION
#
# ###############################################

# Supported extensions of archive files 
$extensions = '(zip|rar|tgz|tar\.gz|tar|7z)'

# Name of the file recording the name of students
$students_file = 'rendus.txt'

# Name of the CSV file recording the binomials
$binomials_csv_file = 'binomes.csv'

# Name of the text file recording the binomials
$binomials_txt_file = 'binomes.txt'

# Columns names of generated CSV file
$columns_csv = ['Noms binôme', 'Commentaire', 'Note']

# Number of errors while processing
$errors = 0

# ###############################################
#
# TECHNICAL CONSTANTS DEFINITION
# (nothing has to be configured below this point)
#
# ###############################################

# Directory where projects are stored after download
$down_dir = 'zip'

# Log of this script
$log_file = 'fetch_and_sort.log'

# ###############################################
#
# METHODS DEFINITION
#
# ###############################################

#
# ADD AN ENTRY TO THE LOG FILE
#

def add_log(msg)
  File.open($log_file, 'a') { |file| file << msg }
end

#
# FETCH PROJECTS FROM A LOCAL ARCHIVE FILE
#

def fetch_projects(filename)
  FileUtils::rm_rf($down_dir)
  FileUtils::mkdir($down_dir)
  system("cd #{$down_dir} && unzip #{filename}")
end

#
# RENAME A FILE WITH WRONG NAMING CONSTRAINTS
#

def rename_file(f)
  puts "No student names found for #{f} (file does not follow naming constraints)"
  puts "Could you rename the file ?"
  new_name = ''
  while new_name.empty?
    new_name = STDIN.gets.strip
  end
  FileUtils::mv($down_dir + '/' + f, $down_dir + '/' + new_name)
  add_log("*** Fichier #{f} renommé en #{new_name} ***\n")
  return new_name
end

#
# PARSE AN ARCHIVE FILE IN ORDER TO EXTRACT RELATED NAMES AND GROUP
#

def names_and_group(f, groups)
  names = nil
  group = groups[0] if groups.length == 1

  while !names
    if groups.length == 1
      if f =~ /TP_([a-z][a-z0-9]*)_([a-z][a-z0-9]*)_([a-z][a-z0-9]*).#{$extensions}$/i
        names = [$1, $2, $3]
      elsif f =~ /TP_([a-z][a-z0-9]*)_([a-z][a-z0-9]*).#{$extensions}$/i
        names = [$1, $2]
      elsif f =~ /TP_([a-z][a-z0-9]*).#{$extensions}/i
        names = [$1]
      end
    else
      groups.each do |g|
        if f =~ /TP_#{g}_([a-z][a-z0-9]*)_([a-z][a-z0-9]*)_([a-z][a-z0-9]*).#{$extensions}$/i
          names = [$1, $2, $3]
          break
        elsif f =~ /TP_#{g}_([a-z][a-z0-9]*)_([a-z][a-z0-9]*).#{$extensions}$/i
          names = [$1, $2]
          break
        elsif f =~ /TP_#{g}_([a-z][a-z0-9]*).#{$extensions}/i
          names = [$1]
          break
        end
      end
      group = g
    end

    if names.nil?
      f = rename_file(f)
    else
      add_log "#{f} => #{names.inspect}\n"
    end
  end

  return names, group, f
end

#
# NORMALIZATION PART
#

def normalize(groups)
  # Creation of a sub-directory for each group
  
  groups.each do |g|
    FileUtils::rm_rf(g)
    FileUtils::mkdir(g)
  end

  # Names of students and binomials
  name_students = []
  names_binomials = []

  # Process the archives

  (Dir::entries($down_dir) - ['.', '..', '.directory']).each do |e|

    # Create a directory for each project and each group (if several are available)
    # Also record name of binomials

    names, group, e = names_and_group(e, groups)    
    target = "#{group}/#{names.sort.join('_')}".upcase
    names_binomials << names.collect! { |name| name.capitalize }.sort

    # Extract original archive in a temporary place
    
    FileUtils::rm_rf("tmp")
    FileUtils::mkdir("tmp")

    if e =~ /.zip$/i
      system("cd tmp && unzip \"../#{$down_dir}/#{e}\"")
    elsif e =~ /.rar$/i
      system("cd tmp && unrar x \"../#{$down_dir}/#{e}\"")
    elsif e =~ /.tar.gz$/i || e =~ /.tgz$/i
      system("cd tmp && tar xvzf \"../#{$down_dir}/#{e}\"")
    elsif e =~ /.tar$/i
      system("cd tmp && tar xvf \"../#{$down_dir}/#{e}\"")
    elsif e =~ /.7z$/i
      system("cd tmp && 7zr x \"../#{$down_dir}/#{e}\"")
    end
    if $? != 0
      add_log "** Error while uncompressing #{e}\n **"
      $errors += 1
    end
    
    # Move all extracted files at the root whenever it is not the case
    
    if (Dir::entries('tmp') - ['.', '..', '__MACOSX']).length == 1
      single_file = (Dir::entries('tmp') - ['.', '..', '__MACOSX'])[0]
      
      # Do we handle a file or a directory?
      if (File.directory?('tmp/' + single_file))
        src = 'tmp/' + single_file
      else
        src = 'tmp'
      end
    else
      src = 'tmp'
    end

    # Set the rights

    FileUtils::chmod_R(0755, src)

    # Use git in order to follow local updates
    #   -> git clean -fx : to clean all new files
    #   -> git reset --hard [HEAD] : to restore initial state

    system("cd #{src} && git init && git add . && git commit -m 'Initial commit' && git tag original")

    # Move the temporary directory to another one with a normalized name
    
    FileUtils::mv(src, target)

    # Record who has contributed to the current project
    
    names.each do |name|
      name_students << name.capitalize
    end
  end

  return name_students, names_binomials
end

#
# GENERATION PART
#

def generate_synthesis(name_students, names_binomials)
  # Create the file recording students names...

  File::open($students_file, 'w') do |f|
    f.puts name_students.sort.join("\n")
  end

  # ...the file recording the binomials names...

  File::open($binomials_txt_file, 'w') do |f|
    names_binomials.sort.each do |b|
      f.puts b.join(" - ")
    end
  end

  # ...and the csv recording binomials names

  File::open($binomials_csv_file, 'w') do |f|
    
    # Generate header
    
    f.puts $columns_csv.join(';')
    sep = ';' * ($columns_csv.length - 1)
    
    # Generate a line per binomials

    names_binomials.sort.each do |b|
      f.puts b.join(" - ") + sep
    end
  end

  # Cleanup

  FileUtils::rm_rf("tmp")
  puts "\n*******************************************************"
  puts "#{name_students.length} étudiants ont rendus leur devoir"
  puts "*******************************************************\n"
end

#
# INPUT PARAMETERS
#

def read_parameters
  # First, display command-line usage

  puts '########################################################################'
  puts "Command-line usage: #{$0} <groups list> <zip archive file>"
  puts "########################################################################\n\n"

  # Name of the group(s)

  groups = []
  puts '-> Name of the groups'
  puts '   Tips: One line per group, group expressed in upcase,'
  puts '         blankline to finish'
  puts '   Examples: S1BIS, ASRALL, AS, S1C, S2A'
  puts '------------------------------------------------------'
  
  again = true

  while again
    answer = STDIN.gets.strip
    if !answer.empty?
      groups << answer
    else
      if !groups.empty?
        again = false
      end
    end
  end

  # File to be used

  puts '-> Archive filename'
  puts '   Tips: First download all projects thanks to Arche'
  puts '   Example: path/module-name-comments-id.zip...'
  puts '------------------------------------------'

  filename = ''
  filename = STDIN.gets.strip while filename.empty?

  return groups, filename
end

# ###########
#
# MAIN METHOD
#
# ###########

def fetch_and_sort
  # Handle the different ways allowing to launch the script,
  # either interactive or commandline based

  if ARGV.length == 0
    groups, filename = read_parameters
  else
    groups = ARGV[0...(ARGV.length - 1)]
    filename = ARGV[ARGV.length - 1]

    # As the archive is uncompressed in a subdirectory,
    # prefix the path in the case this last one is relative

    filename = '../' + filename unless filename =~ /^\//
  end
  fetch_projects(filename)
  name_students, names_binomials = normalize(groups)
  generate_synthesis(name_students, names_binomials)
end

#
# Init the log file and call to main method
#

FileUtils::rm_rf($log_file)
fetch_and_sort

if ($errors != 0)
  puts "#{$errors} error(s) found, please check log file."
end

# PROCESS THE PROJECT

# To be done in another script
