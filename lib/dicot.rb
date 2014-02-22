require 'wapiti'
require 'treat'

require_relative 'tokenizer'
require_relative 'trainer'

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
        char_pos += 1 if string[char_pos] == " "
        #require 'pry'; binding.pry
      end

      Trainer.add_training_seq(data)
    end
  end
end
