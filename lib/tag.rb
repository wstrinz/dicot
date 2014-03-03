class Dicot
  class Tag
    class << self
      def raw_label(string)
        tokens = Tokenizer.tokenize(string)
        labels = CRF.label([tokens])
        labels
      end

      def label(string)
        char_pos = 0
        tags = raw_label(string).first.each_with_object([]) do |raw, arr|
          case raw.last[0]
          when "B"
            arr << {
              string: raw.first,
              tag: raw.last[2..-1],
              start: char_pos,
              end: char_pos + raw.first.size - 1
            }
          when "I"
            arr.last[:string] += " " if string[char_pos - 1] == " "
            arr.last[:string] += "#{raw.first}"
            arr.last[:end] = char_pos + raw.first.size - 1
          when "O"
          else
            raise "Invalid BIO encoding for #{raw}"
          end

          char_pos += raw.first.size
          char_pos += 1 if string[char_pos] == " "
        end

        tags
      end

      def labels
        (CRF::model.labels - ['O']).map{|l| l[2..-1]}.uniq
      end

      def train(string, tags)
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

        CRF.add_training_seq(data)
      end
    end
  end
end
