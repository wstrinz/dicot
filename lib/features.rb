class Dicot
  class Features
    class << self
      def raw_label(string)
        tokens = Tokenizer.tokenize(string)
        labels = Trainer.label([tokens])
        labels
      end

      def label(string, add_to_feedback=true)
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

        Trainer.feedback_queue << { string: string, tags: tags } if add_to_feedback

        tags
      end
    end
  end
end
