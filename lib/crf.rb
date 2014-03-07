require 'wapiti'

class Dicot
  class CRF
    MODEL_PATH = 'model/'
    TRAINING_PATH = 'model/train.txt'
    TRAINING_BASE = 'model/train'
    PATTERN_PATH = 'model/pattern.txt'

    class << self
      def model_full_path
        MODEL_PATH + Dicot.model_id + ".mod"
      end

      def training_full_path
        TRAINING_BASE + "/" + Dicot.model_id
      end

      def aggregated_training_file_path
        File.join(training_full_path, "train.txt")
      end

      def create_model_dir_if_not_exist
        folder = MODEL_PATH + Dicot.model_id
        unless File.exist?(folder)
          Dir.mkdir(folder)
        end
      end

      def create_training_dir_if_not_exist
        folder = TRAINING_BASE + "/" + Dicot.model_id
        unless File.exist?(folder)
          Dir.mkdir(folder)
        end
      end

      def model
        unless @model || File.exist?(model_full_path)
          retrain(TRAINING_BASE + "/default.txt")
          create_model_dir_if_not_exist
          @model.save(model_full_path)
        end

        @model ||= Wapiti.load(model_full_path)
      end

      def reset_model!
        @model = nil
        model
      end

      def save
        create_model_dir_if_not_exist
        model.compact.save(model_full_path)
      end

      def label(data)
        model.label(data)
      end

      def dump_queue
        create_training_dir_if_not_exist
        file_name = "#{Time.now.to_i}_train.txt"

        open(File.join(training_full_path, file_name), 'w') do |f|
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
        create_training_dir_if_not_exist
        open(aggregated_training_file_path, 'w') do |overall_file|
          Dir[File.join(training_full_path, '/**')].each do |f|
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

          @model = Wapiti::Model.train(aggregated_training_file_path, pattern: PATTERN_PATH)
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
