#!/usr/bin/ruby -w

require 'Qt4'

# External commands to be launched foreach selected project
$external_commands = []
$external_commands << 'kate *.java resultats/rapport.txt'
$external_commands << 'kdiff3 sortie*.txt ../../sortie.txt'
$external_commands << 'kdiff3 sortie*.txt ../../sortie-utf.txt'
$external_commands << 'konqueror doc/index.html'

# Class launching all needed processes for correction
class ProjectCorrection < Qt::Object
  slots 'launch_correction()'

  def initialize(parent = nil)
    super
  end

  def launch_correction
    project_name = sender.text
    Dir.chdir(project_name) do
      $external_commands.each do |ec|
        fork { exec(ec) }
      end
    end
  end
end

# What are the available projects?
projects = (Dir::entries('.') - ['.', '..']).sort

# Keep only directories
projects.delete_if { |p| !File.directory?(p) }

# Buttons
buttons = []

# Correction instance
correction = ProjectCorrection.new

# Interface building, connection setting up and execution
Qt::Application.new(ARGV) do
  Qt::Widget.new do

    self.window_title = 'Choose a project...'
    
    projects.each do |p|
      button = Qt::PushButton.new(p)
      connect(button, SIGNAL('clicked()'), 
              correction, SLOT('launch_correction()'))
      buttons << button
    end
    
    self.layout = Qt::VBoxLayout.new do
      buttons.each do |b|
        add_widget(b, 0, Qt::AlignCenter)
      end
    end
 
    show
  end
  
  exec
end
