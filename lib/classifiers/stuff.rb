class Dicot
  class Classifiers
    class Stuff
      include Dicot::Classify
      attr :internal_model

      def initialize(dicot_model)
        StuffClassifier::Base.storage = StuffClassifier::FileStorage.new(File.join(dicot_model.model_base_path, dicot_model.name))
        @internal_model = StuffClassifier::Bayes.new(dicot_model.name, purge_state: false)
      end

      def reset!
        name = @internal_model ? @internal_model.name : "default"
        @internal_model = StuffClassifier::Bayes.new(name, purge_state: true)
      end

      def labels
        internal_model.categories
      end

      def train(string, klass)
        training_queue << [string, klass]
      end

      def classify(string)
        if labels.size == 0
          ""
        elsif labels.size == 1
          labels.first
        else
          begin
            klass = internal_model.classify(string)
            feedback_queue << [string, klass]
            klass
          rescue => e
            puts "W: Classification error - #{e.message}" unless Dicot.surpress_warnings?
            "{error}"
          end
        end
      end

      def retrain
        training_queue.each do |str, klass|
          internal_model.train(klass, str)
        end
        training_queue.clear

        internal_model.save_state
      end

      def items
        model.items
      end
    end
  end
end
