class Dicot
  class Classify
    class << self
      def model
        @model ||= Classifier::LSI.new
      end

      def train(string, klass)
        model.add_item string, klass
      end

      def classify(string)
        model.classify(string)
      end

      def items
        model.items
      end
    end
  end
end
