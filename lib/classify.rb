require 'stuff-classifier'

class Dicot
  module Classify
    include Trainable
    extend HasRegistry

    class << self
      def included(mod)
        if mod.class_variable_defined?(:@@class_symbol)
          sym = mod.class_variable_get(:@@class_symbol).to_sym
        else
          sym = mod.to_s.split("::").last.camel_case.downcase.to_sym
        end

        registry[sym] = mod
      end
    end

    def classify(string)
      raise "Classifier #{self} failed to implement the classify method"
    end
  end
end
