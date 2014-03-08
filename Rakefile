require 'rake'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

task :default => [:test]
RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)

desc "run tests"
task :test => [:spec, :features]

namespace :clean do
  desc "remove model and training files"
  task :all do
    expected_model_files = %w{model/model.mod model/pattern.txt model/train}
    expected_train_files = %w{model/train/default.txt}

    (Dir["model/**"] - expected_model_files).each do |f|
      puts "remove #{f}"
      FileUtils.rm_rf f
    end

    (Dir["model/train/**"] - expected_train_files).each do |f|
      puts "remove #{f}"
      FileUtils.rm_rf f
    end
  end
end
