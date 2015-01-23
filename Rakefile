require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

PATCH = 2
MINOR = 1
MAJOR = 0

desc "Commit patch and release gem"
task :patch, :commit_message do |t, args|
  update(args[:commit_message]){ |sv,i| i == PATCH ? sv.succ : sv }
end

desc "Commit minor update and release gem"
task :minor, :commit_message do |t, args|
  update(args[:commit_message]) do |sv,i| 
    case i
    when MINOR then sv.succ
    when PATCH then "0"
    else sv
    end
  end
end

desc "Commit major update and release gem"
task :major, :commit_message do |t, args|
  update(args[:commit_message]){ |sv,i| i == MAJOR ? sv.succ : "0" }
end


def update(msg)
  # Update version
  File.open "./lib/obelisk/version.rb", "r+" do |f|
    up = f.read.sub(/\d+.\d+.\d+/) { |ver| ver.split('.').map.with_index{ |sv, i| yield sv,i }.join('.') }
    f.seek 0
    f.write up
  end
  puts "Changed version."
  puts "Removed #{File.delete(*Dir['./*.gem'])} old gems"
  # add new files to repo
  %x(git add --all .)
  # commit
  if msg then %x(git commit -a -m "#{msg}")
  else %x(git commit -a --reuse-message=HEAD); end
  %x(git push)
  puts "Pushed to github."
  Dir["./*.gemspec"].each { |spec| puts %x(gem build #{spec}) }
  Dir["./*.gem"].each { |gem| puts %x(gem push #{gem}) }
end