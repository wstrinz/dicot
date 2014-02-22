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
				unless File.exist? 'model/model.mod'
					Wapiti::Model.train([['zsdxye O','ZxFDSG I', 'd O']], pattern: 'model/pattern.txt').compact.save('model/model.mod')
				end

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

			def training_buffer
				@training_buffer ||= []
			end

			def add_training_seq(data)
				training_buffer << data
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

		def train(string, tags)
			char_pos = 0
			data = Tokenizer.tokenize(string).each_with_object([]) do |token, arr|
				loc = tags.keys.find{|loc| char_pos.between?(loc[0], loc[1])}
				if loc
					arr << [token, tags[loc]]
				else
					arr << [token, "O"]
				end

				char_pos += token.size
				char_pos += 1 if string[char_pos + 1] == " "
			end

				#require 'pry'; binding.pry
			Trainer.add_training_seq(data)
		end
  end
end
