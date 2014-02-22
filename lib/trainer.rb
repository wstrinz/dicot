class Dicot
  class Trainer
    class << self
      def model
        unless File.exist? 'model/model.mod'
          Wapiti::Model.train([['zz O','zz B']], pattern: 'model/pattern.txt').compact.save('model/model.mod')
        end

        @model ||= Wapiti.load('model/model.mod')
      end

      def save
        model.compact.save
      end

      def label(data)
        model.label(data)
      end

      def retrain(data=:none)
        unless data == :none
          open('model/train.txt','a') do |f|
            f.write "\n"
            data.each do |d|
              f.write d.join(" ") + "\n"
            end
          end
        end
        if training_buffer.size > 0
          open('model/train.txt','a') do |f|
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

        @model = Wapiti::Model.train('model/train.txt', pattern: 'model/pattern.txt')
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
