class Dicot
  DICOT_BASE = File.expand_path File.join(File.dirname(__FILE__), '..')
end

Dir['lib/mixins/**'].each do |f|
  require File.join Dicot::DICOT_BASE, f
end

require_relative 'tokenizer'
require_relative 'tag'
require_relative 'classify'
require_relative 'model'

Dir[File.join(Dicot::DICOT_BASE, 'lib/classifiers/**')].each do |f|
  require f
end

Dir[File.join(Dicot::DICOT_BASE, 'lib/taggers/**')].each do |f|
  require f
end

Dir[File.join(Dicot::DICOT_BASE, 'lib/tokenizers/**')].each do |f|
  require f
end

class Dicot
  class << self
    def label(string, add_to_feedback=true)
      lab = {
        string: string,
        tags: features(string),
        class: classify(string)
      }

      model.tagger.feedback_queue << lab if add_to_feedback

      lab
    end

    def features(string)
      model.label(string)
    end

    def classify(string)
      model.classify(string)
    end

    def train(string, tags, klass=nil)
      model.train(string, tags, klass)
    end

    def retrain
      model.retrain
    end

    def feedback_queue
      model.tagger.feedback_queue
    end

    def model
      @model ||= Model.new(surpress_warnings: surpress_warnings?)
    end

    def reset_model!(name="default")
      @model = Model.new(name: name, surpress_warnings: surpress_warnings?)
    end

    def surpress_warnings?
      @surpress_warnings ||= false
    end

    def surpress_warnings=(value)
      @surpress_warnings = value
    end
  end
end
