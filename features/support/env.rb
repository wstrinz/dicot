require 'capybara'
require 'capybara/cucumber'
require 'capybara/webkit'

require_relative '../../lib/server/server'

Capybara.app = Dicot::Server

Capybara.javascript_driver = :webkit

Before do
  if !$retrained
    save_model
    enumerate_training_files
    train_on_fixtures
    train_classifier_on_fixtures
    $retrained = true
  end
end

at_exit do
  remove_fixtures
  remove_generated_training_files
  restore_model
end

def train_on_fixtures
  Dicot.model.tagger.retrain('spec/fixtures/train.txt')
  if File.exist? 'model/train.txt'
    FileUtils.copy 'model/train.txt', 'model/train.txt.bak'
  end

  FileUtils.copy 'spec/fixtures/train.txt', 'model/train.txt'
end

def train_classifier_on_fixtures
  Dicot.model.classifier.train("Where's Will? (Friday Morning)", "Out of Office")
  Dicot.model.classifier.retrain
end

def enumerate_training_files
  $existing_training_files = Dir["model/**"] + Dir["model/train/**"]
end

def remove_generated_training_files
  extra_files = Dir["model/**"] + Dir["model/train/**"] - $existing_training_files
  extra_files.each do |f|
    FileUtils.rm_rf f
  end
end

def remove_fixtures
  if File.exist? 'model/train.txt.bak'
    FileUtils.copy 'model/train.txt.bak', 'model/train.txt'
    FileUtils.rm 'model/train.txt.bak'
  end
end

def save_model
  $original_model = IO.read('model/model.mod')
end

def restore_model
  open('model/model.mod','w'){|f| f.write $original_model}
end
