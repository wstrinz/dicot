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
      in_label = false

      data = Tokenizer.tokenize(string).each_with_object([]) do |token, arr|
        loc = tags.keys.find{|l| char_pos.between?(l[0], l[1])}
        if loc
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

      Trainer.add_training_seq(data)
    end

    def retrain
      Dicot::Trainer.retrain
    end
  end
end
