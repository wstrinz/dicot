require 'wapiti'
require 'treat'

require_relative 'tokenizer'
require_relative 'trainer'

class Dicot
  class << self
    def raw_label(string)
      tokens = Tokenizer.tokenize(string)
      labels = Trainer.label([tokens])
      labels
    end

    def label(string)
      labels = raw_label(string).first.each_with_object([]) do |raw, arr|
        case raw.last[0]
        when "B"
          arr << [raw.first, raw.last[2..-1]]
        when "I"
          arr.last[0] += " #{raw.first}"
        when "O"
        else
          raise "Invalid BIO encoding for #{raw}"
        end
      end
      Hash[labels]
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
      end

      Trainer.add_training_seq(data)
    end
  end
end
