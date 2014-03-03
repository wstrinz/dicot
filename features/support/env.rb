require 'capybara'
require 'capybara/cucumber'
require 'capybara/webkit'

require_relative '../../lib/server/server'

Capybara.app = Dicot::Server

Capybara.javascript_driver = :webkit

Before do
  if !$retrained
    enumerate_training_files
    train_on_fixtures
    train_classifier_on_fixtures
    $retrained = true
  end
end

at_exit do
  remove_fixtures
  remove_generated_training_files
end

def train_on_fixtures
  Dicot::CRF.retrain('spec/fixtures/train.txt')
  if File.exist? 'model/train.txt'
    FileUtils.copy 'model/train.txt', 'model/train.txt.bak'
  end

  FileUtils.copy 'spec/fixtures/train.txt', 'model/train.txt'
end

def train_classifier_on_fixtures
  Dicot::Classify.train("Where's Will? (Friday Morning)", "Out of Office")
end

def enumerate_training_files
  $existing_training_files = Dir["model/train/**"]
end

def remove_generated_training_files
  extra_files = Dir["model/train/**"] - $existing_training_files
  extra_files.each do |f|
    FileUtils.rm f
  end
end

def remove_fixtures
  if File.exist? 'model/train.txt.bak'
    FileUtils.copy 'model/train.txt.bak', 'model/train.txt'
    FileUtils.rm 'model/train.txt.bak'
  end
end
