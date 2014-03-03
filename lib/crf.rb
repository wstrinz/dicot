require 'wapiti'

class Dicot
  class CRF
    MODEL_PATH = 'model/model.mod'
    TRAINING_PATH = 'model/train.txt'
    TRAINING_BASE = 'model/train'
    PATTERN_PATH = 'model/pattern.txt'

    class << self
      def model
        unless File.exist? MODEL_PATH
          retrain(TRAINING_BASE + "/default.txt")
          @model.save(MODEL_PATH)
        end
        @model ||= Wapiti.load(MODEL_PATH)
      end

      def save
        model.compact.save(MODEL_PATH)
      end

      def label(data)
        model.label(data)
      end

      def dump_queue
        file_name = "#{Time.now.to_i}_train.txt"
        open(File.join(TRAINING_BASE, file_name), 'w') do |f|
          training_queue.each do |ent|
            ent.each do |d|
              f.write d.join(" ") + "\n"
            end
            f.write "\n"
          end
          training_queue.clear
        end
      end


      def aggregate_training_files
        open(TRAINING_PATH, 'w') do |overall_file|
          Dir[TRAINING_BASE + '/**'].each do |f|
            overall_file.write(IO.read f)
          end
        end
      end

      def retrain(training_file=:none)
        Classify.training_queue.each do |str, klass|
          Classify.train(str, klass)
        end

        if training_file == :none
          if training_queue.size > 0
            dump_queue
          end

          aggregate_training_files

          @model = Wapiti::Model.train(TRAINING_PATH, pattern: PATTERN_PATH)
        else
          @model = Wapiti::Model.train(training_file, pattern: PATTERN_PATH)
        end
      end

      def training_queue
        @training_queue ||= []
      end

      def feedback_queue
        @feedback_queue ||= []
      end

      def feedback_queue=(queue)
        @feedback_queue = queue
      end

      def add_training_seq(data)
        training_queue << data
      end
    end
  end
end
