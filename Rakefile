require 'rake'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

task :default => [:test]
RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)

task :test do
  Rake::Task["spec"].invoke
  Rake::Task["features"].invoke
end
