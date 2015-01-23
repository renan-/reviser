#!/usr/bin/ruby -w

require 'fileutils'

def getnames(f)
  names = nil
  if f =~ /^([^_.]*)_([^_.]*)$/i
    names = [$1, $2]
    puts "#{f} => #{names.inspect}"
  elsif f =~ /^([^_.]*)$/i
    names = [$1]
    puts "#{f} => #{names.inspect}"
  end
  if names.nil?
    puts "Could not find names for #{f}"
  end
  return names
end

$liste = []
g = 'resultats'
FileUtils::rm_rf(g)
FileUtils::mkdir(g)

(Dir::entries('.') - ['.', '..', '.directory', g]).each do |e|
  n = getnames(e)

  if n
    target = "#{n.join('_')}".capitalize
    system("cd #{g} && testsite ../#{e} #{target}")
    $liste << n.join(' ')
  end
end

File::open('rendus.txt', 'w') do |f|
  f.puts $liste.sort.join("\n")
end

# Cleanup and bye

puts "#{$liste.length} devoirs rendus"
