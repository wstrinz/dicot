class Dicot
  module Tag
    include Trainable

    class << self
      def for(symbol)
        Dicot::Taggers::CRF
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
