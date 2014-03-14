require 'stuff-classifier'

class Dicot
  module Classify
    include Trainable

    class << self
      def for(symbol)
        # TODO implement registry
        Dicot::Classifiers::Stuff
      end
    end

    def classify(string)
      raise "Classifier #{self} failed to implement the classify method"
    end
  end
end
