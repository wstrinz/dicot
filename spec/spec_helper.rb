require_relative '../lib/dicot.rb'

def train_on_fixtures
  Dicot::Trainer.retrain('spec/fixtures/train.txt')
  if File.exist? 'model/train.txt'
    FileUtils.copy 'model/train.txt', 'model/train.txt.bak'
  end

  FileUtils.copy 'spec/fixtures/train.txt', 'model/train.txt'
end

def enumerate_training_files
  @existing_training_files = Dir["model/train/**"]
end

def remove_generated_training_files
  extra_files = Dir["model/train/**"] - @existing_training_files
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

def save_training_text
  @original_training_text = IO.read('model/train.txt')
end

def restore_training_text
  open('model/train.txt','w'){|f| f.write @original_training_text}
end

def save_model
  @original_model = IO.read('model/model.mod')
end

def restore_model
  open('model/model.mod','w'){|f| f.write @original_model}
end
