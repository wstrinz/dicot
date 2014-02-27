require 'wapiti'
require 'classifier'
require 'treat'

require_relative 'tokenizer'
require_relative 'trainer'
require_relative 'features'
require_relative 'classify'

class Dicot
  class << self

    def label(string, add_to_feedback=true)
      Features.label(string, add_to_feedback)
    end

    def train(string, tags)
      Trainer.train(string, tags)
    end

    def retrain
      Trainer.retrain
    end
  end
end
