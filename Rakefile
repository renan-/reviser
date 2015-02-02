task :default => %w[clean]

desc "clean the folder (delete logs, projects and results files"
task :clean => [:html, :csv, :xls] do
	entries = ['projects', 'logs']	
	entries.each {|entry| rm_rf entry}
end

desc "Delete html results"
task :html do
	delete FileList.new('*.html')
end

desc "Delete csv results"
task :csv do
	delete FileList.new('*.csv')
end

desc "Delete xls results"
task :xls do
	delete FileList.new('*.xls')
end


def delete(entries)
	entries.each {|entry| rm_rf entry}
end