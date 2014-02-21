require 'wapiti'
require 'treat'

class Dicot
  class Tokenizer
    extend Treat::Core::DSL
    class << self
      def tokenize(string)
        e = entity string
        e.apply(:chunk, :tokenize)
        e.tokens.map(&:to_s)
      end
    end
  end
end

class Dicot
  class Trainer
    class << self
      def model
        @model ||= Wapiti.load('model/model.mod')
      end

      def save
        model.compact.save
      end

      def label(data)
        model.label(data)
      end

      def retrain(data)
        open('model/train.txt','a') do |f|
          f.write "\n"
          data.each do |d|
            f.write d.join(" ") + "\n"
          end
        end

        model.train('model/train.txt')
        model
      end
    end
  end
end

class Dicot
  class << self
    def label(string)
      tokens = Tokenizer.tokenize(string)
      labels = Trainer.label([tokens])
      labels
    end
  end
end
