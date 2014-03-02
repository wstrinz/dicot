class Dicot
  class Classify
    class << self
      def model
        #@model ||= Classifier::LSI.new
        @model ||= StuffClassifier::Bayes.new("Dicot")
      end

      def reset!
        #@model = Classifier::LSI.new
        @model = nil
        model
      end

      def classes
        #@classes ||= Set.new
        model.categories
      end

      def train(string, klass)
        #classes << klass
        #model.add_item string, klass
        model.train(klass, string)
      end

      def training_queue
        @training_queue ||= []
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
