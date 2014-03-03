require 'wapiti'
require 'stuff-classifier'
require 'treat'

require_relative 'tokenizer'
require_relative 'crf'
require_relative 'tag'
require_relative 'classify'

class Dicot
  class << self
    def label(string, add_to_feedback=true)
      lab = {
        string: string,
        tags: features(string),
        class: classify(string)
      }

      CRF.feedback_queue << lab if add_to_feedback

      lab
    end

    def features(string)
      Tag.label(string)
    end

    def classify(string)
      Classify.classify(string)
    end

    def train(string, tags, klass=nil)
      CRF.train(string, tags, klass)
    end

    def retrain
      CRF.retrain
    end

    def feedback_queue
      CRF.feedback_queue
    end

    def surpress_warnings?
      @surpress_warnings ||= false
    end

    def surpress_warnings=(value)
      @surpress_warnings = value
    end
  end
end
