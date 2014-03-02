class Dicot
  class Trainer
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

      def dump_buffer
        file_name = "#{Time.now.to_i}_train.txt"
        open(File.join(TRAINING_BASE, file_name), 'w') do |f|
          training_buffer.each do |ent|
            ent.each do |d|
              f.write d.join(" ") + "\n"
            end
            f.write "\n"
          end
          training_buffer.clear
        end
      end

      def train(string, tags, klass=nil)
        Classify.training_queue << [string, klass] if klass

        char_pos = 0
        in_label = false
        current_label = nil

        data = Tokenizer.tokenize(string).each_with_object([]) do |token, arr|
          loc = tags.keys.find{|l| char_pos.between?(l[0], l[1])}
          if loc
            unless current_label && tags[loc] == current_label
              in_label = false
            end
            current_label = tags[loc]

            if in_label
              arr << [token, "I-#{tags[loc]}"]
            else
              arr << [token, "B-#{tags[loc]}"]
            end
            in_label = true
          else
            arr << [token, "O"]
            in_label = false
          end

          char_pos += token.size
          char_pos += 1 if string[char_pos] == " "
        end

        add_training_seq(data)
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
          if training_buffer.size > 0
            dump_buffer
          end

          aggregate_training_files

          @model = Wapiti::Model.train(TRAINING_PATH, pattern: PATTERN_PATH)
        else
          @model = Wapiti::Model.train(training_file, pattern: PATTERN_PATH)
        end
      end

      def training_buffer
        @training_buffer ||= []
      end

      def feedback_queue
        @feedback_queue ||= []
      end

      def feedback_queue=(queue)
        @feedback_queue = queue
      end

      def add_training_seq(data)
        training_buffer << data
      end
    end
  end
end
