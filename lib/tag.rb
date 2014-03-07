class Dicot
  class Tag
    class << self
      def raw_label(string)
        tokens = Tokenizer.tokenize(string)
        labels = CRF.label([tokens])
        labels
      end

      def token_map(string)
        copy = string.clone
        map = {}
        pos = 0
        Tokenizer.tokenize(string).each do |token|
          start = pos + copy.index(token)
          ed = start + token.length - 1
          map[[start, ed]] = string[start..ed]
          pos = ed + 1
          copy = string[pos..-1]
        end

        map
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
        map = token_map(string)

        if tags.empty?
          data = map.values.map{|token| [token, "O"]}
        else
          data = []
          tags.keys.each_with_index do |loc, i|
            st = loc[0]
            ed = loc[1]

            tokens = map.select{|t|
              t[0].between?(st, ed) &&
              t[1].between?(st, ed)
            }.to_a

            # handle in between's (should be tagged "O")
            if i > 0
              last = tags.keys[i-1]
              in_between = map.select do |t|
                t[0].between?(last[1], st) &&
                t[1].between?(last[1], st)
              end
            else
              in_between = map.select do |t|
                t[0].between?(0, st) &&
                t[1].between?(0, st)
              end
            end

            unless in_between.empty?
              in_between.values.each do |token|
                data << [token, 'O']
              end
            end

            unless tokens.empty?
              data << [tokens.first.last, "B-#{tags[loc]}"]

              tokens[1..-1].each do |token|
                data << [token.last, "I-#{tags[loc]}"]
              end
            end
          end

          # handle endings
          last_tag_loc = tags.keys.max_by(&:last)

          map.keys.select{|k| k[1] > last_tag_loc[1] }.each do |loc|
            data << [map[loc], 'O']
          end

        end

        CRF.add_training_seq(data)
      end
    end
  end
end
