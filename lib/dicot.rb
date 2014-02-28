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
      l = {
        string: string,
        tags: features(string),
        class: classify(string)
      }

      Trainer.feedback_queue << l if add_to_feedback

      l
    end

    def features(string)
      Features.label(string)
    end

    def classify(string)
      Classify.classify(string)
    end

    def train(string, tags)
      Trainer.train(string, tags)
    end

    def retrain
      Trainer.retrain
    end

    def feedback_queue
      Trainer.feedback_queue
    end

    def surpress_warnings?
      @surpress_warnings ||= false
    end

    def surpress_warnings=(value)
      @surpress_warnings = value
    end
  end
end
