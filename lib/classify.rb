class Dicot
  class Classify
    class << self
      def model
        @model ||= Classifier::LSI.new
      end

      def reset!
        @model = Classifier::LSI.new
      end

      def classes
        @classes ||= Set.new
      end

      def train(string, klass)
        classes << klass
        model.add_item string, klass
      end

      def classify(string)
        if classes.size == 0
          ""
        elsif classes.size == 1
          classes.first
        else
          begin
            model.classify(string)
          rescue
            puts "W: Classification error" unless Dicot.surpress_warnings?
            "{error}"
          end
        end
      end

      def items
        model.items
      end
    end
  end
end
