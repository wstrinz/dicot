class Dicot
  module Tag
    extend HasRegistry
    include Trainable

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

    def label(string)
      raise "Tagger #{self} failed to implement label method"
    end

    def labels
      raise "Tagger #{self} failed to implement labels method"
    end

    def train(string, tags)
      raise "Tagger #{self} failed to implement train method"
    end

    def save
      raise "Tagger #{self} failed to implement save method"
    end

    def load
      raise "Tagger #{self} failed to implement load method"
    end
  end
end
