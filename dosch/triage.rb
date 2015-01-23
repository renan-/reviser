#!/usr/bin/ruby -w

require 'fileutils'

# Name of the group(s)
# Please note that group has to be expressed in upcase
# $groupes = ['S1A', 'S1B', 'S1C', 'S1D', 'S1E', 'AS']
$groupes = ['S2BIS']

# Supported extensions of archive files 
$extensions = '(zip|rar|tgz|tar\.gz)'

# Names of students and binomials
$nom_etudiants = []
$noms_binomes = []

# Columns names of generated CSV file
$columns_csv = ['Noms binôme', 'Commentaire', 'Note']

# Parse an archive file whenever its name includes a group

def getnames_with_group(f)
  names = nil
  $groupes.each do |g|
    if f =~ /TP_#{g}_([^_]*)_([^_]*)_([^_]*).#{$extensions}$/i
      names = [g, [$1, $2, $3]]
      puts "#{f} => #{names.inspect}"
      break
    elsif f =~ /TP_#{g}_([^_]*)_([^_]*).#{$extensions}$/i
      names = [g, [$1, $2]]
      puts "#{f} => #{names.inspect}"
      break
    elsif f =~ /TP_#{g}_([^_]*).#{$extensions}/i
      names = [g, [$1]]
      puts "#{f} => #{names.inspect}"
      break
    end
  end
  if names.nil?
    puts "Could not find names for #{f}"
    exit(1)
  end
  return names
end

# Parse an archive file whenever its name does not include a group

def getnames_without_group(f)
  names = nil
  if f =~ /TP_([^_]*)_([^_]*)_([^_]*).#{$extensions}$/i
    names = [$1, $2, $3]
    puts "#{f} => #{names.inspect}"
  elsif f =~ /TP_([^_]*)_([^_]*).#{$extensions}$/i
    names = [$1, $2]
    puts "#{f} => #{names.inspect}"
  elsif f =~ /TP_([^_]*).#{$extensions}/i
    names = [$1]
    puts "#{f} => #{names.inspect}"
  end
  if names.nil?
    puts "Could not find names for #{f}"
    exit(1)
  end
  return names
end

# Creation of a sub-directory for each group

$groupes.each do |g|
  FileUtils::rm_rf(g)
  FileUtils::mkdir(g)
end

#
# PROCESS THE ARCHIVES
#

(Dir::entries('zip') - ['.', '..', '.directory']).each do |e|

  # Create a directory for each project and each group (if several are available)
  # Also record name of binomials
  
  if $groupes.length == 1
    n = getnames_without_group(e)
    target = "#{$groupes[0]}/#{n.sort.join('_')}".upcase
    $noms_binomes << n.collect! {|nom| nom.capitalize}.sort
  else
    n = getnames_with_group(e)
    target = "#{n[0]}/#{n[1].sort.join('_')}".upcase
    $noms_binomes << n[1].collect! {|nom| nom.capitalize}.sort
  end

  # Extract original archive in a temporary place
  
  FileUtils::rm_rf("tmp")
  FileUtils::mkdir("tmp")

  if e =~ /.zip$/i
    system("cd tmp && unzip ../zip/#{e}")
  elsif e =~ /.rar$/i
    system("cd tmp && unrar x ../zip/#{e}")
  elsif e =~ /.tar.gz$/i || e =~ /.tgz$/i
    system("cd tmp && tar xvzf ../zip/#{e}")
  end
  if $? != 0
    puts "Error while uncompressing #{e}"
    exit(1)
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

  # Move the temporary directory to another one with a normalized name
  
  FileUtils::mv(src, target)

  # Record who has contributed to the current project
  
  n.each do |name|
    $nom_etudiants << name.capitalize
  end
  
end

# Create the file recording students names

File::open('rendus.txt', 'w') do |f|
  f.puts $nom_etudiants.sort.join("\n")
end

# And the csv recording binomials names

File::open('binomes.csv', 'w') do |f|
  
  # Generate header
  
  f.puts $columns_csv.join(';')
  sep = ';' * ($columns_csv.length - 1)
  
  # Generate a line per binomials

  $noms_binomes.sort.each do |b|
    f.puts b.join(" - ") + sep
  end
end

# Cleanup

FileUtils::rm_rf("tmp")
puts "\n*******************************************************"
puts "#{$nom_etudiants.length} étudiants ont rendus leur devoir"
puts "*******************************************************\n"

# PROCESS THE PROJECT

# To be done in another script
