task :default => %w[cleanup]

desc "CLean the folde (delete logs, projects and results file"
task :cleanup do
  dirs = [
    'logs',
    'projects',
    'results.csv',
    'results.html',
    'results.xls',
  ]
  dirs.each {|dir| rm_rf dir}
end