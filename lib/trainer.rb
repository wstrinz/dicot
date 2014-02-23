class Dicot
  class Trainer
    MODEL_PATH = 'model/model.mod'
    TRAINING_PATH = 'model/train.txt'
    PATTERN_PATH = 'model/pattern.txt'

    class << self
      def model
        if File.exist? MODEL_PATH
          @model ||= Wapiti.load(MODEL_PATH)
        else
          Wapiti::Model.train([['zz O']], pattern: PATTERN_PATH).save(MODEL_PATH)
          @model = Wapiti.load(MODEL_PATH)
        end

      end

      def save
        model.compact.save(MODEL_PATH)
      end

      def label(data)
        model.label(data)
      end

      def retrain(data=:none)
        unless data == :none
          open(TRAINING_PATH,'a') do |f|
            f.write "\n"
            data.each do |d|
              f.write d.join(" ") + "\n"
            end
          end
        end
        if training_buffer.size > 0
          open(TRAINING_PATH,'a') do |f|
            f.write "\n"
            training_buffer.each do |ent|
              ent.each do |d|
                f.write d.join(" ") + "\n"
              end
              f.write "\n"
            end
          end

          training_buffer.clear
        end

        @model = Wapiti::Model.train(TRAINING_PATH, pattern: PATTERN_PATH)
        model
      end

      def training_buffer
        @training_buffer ||= []
      end

      def add_training_seq(data)
        training_buffer << data
      end
    end
  end
end
