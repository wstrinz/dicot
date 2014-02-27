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
        begin
          model.classify(string)
        rescue
          puts "W: Classification error" unless Dicot.surpress_warnings?
          "{error}"
        end
      end

      def items
        model.items
      end
    end
  end
end
