require 'wapiti'

class Dicot
  class Taggers
    class CRF
      include Dicot::Tag
      attr :dicot_model

      PATTERN_PATH = 'model/pattern.txt'

      def initialize(dicot_model)
        @dicot_model = dicot_model
      end

      def training_full_path
        File.join(training_base_path, dicot_model.name)
      end

      def aggregated_training_file_path
        File.join(training_full_path, "train.txt")
      end

      def create_training_dir_if_not_exist
        unless File.exist?(training_full_path)
          Dir.mkdir(training_full_path)
        end
      end

      def wapiti_model
        unless @wapiti_model || File.exist?(model_full_path)
          retrain(training_base_path + "/default.txt")
          @wapiti_model.save(model_full_path)
        end

        @wapiti_model ||= Wapiti.load(model_full_path)
      end

      def save
        wapiti_model.compact.save(model_full_path)
      end

      def label(data)
        wapiti_model.label(data)
      end

      def reset_model!
        @wapiti_model = nil
        wapiti_model
      end

      def sort_tags(tags)
        sorted = tags.sort
        sorted.each_with_object({}){|tag, h| h[tag[0]] = tag[1]}
      end

      def raw_label(string)
        tokens = dicot_model.tokenize(string)
        labels = label([tokens])
        labels
      end

      def labels
        (wapiti_model.labels - ['O']).map{|l| l[2..-1]}.uniq
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

      def dump_queue
        create_training_dir_if_not_exist
        file_name = "#{Time.now.to_i}_train.txt"

        open(File.join(training_full_path, file_name), 'w') do |f|
          training_queue.each do |ent|
            ent.each do |d|
              f.write d.join(" ") + "\n"
            end
            f.write "\n"
          end
          training_queue.clear
        end
      end

      def aggregate_training_files
        create_training_dir_if_not_exist
        open(aggregated_training_file_path, 'w') do |overall_file|
          Dir[File.join(training_full_path, '/**')].each do |f|
            overall_file.write(IO.read f)
          end
        end
      end

      def retrain(training_file=:none)
        if training_file == :none
          if training_queue.size > 0
            dump_queue
          end

          aggregate_training_files

          @wapiti_model = Wapiti::Model.train(aggregated_training_file_path, pattern: PATTERN_PATH)
        else
          @wapiti_model = Wapiti::Model.train(training_file, pattern: PATTERN_PATH)
        end
      end

      def train(string, tags)
        tmap = token_map(string)
        tags = sort_tags(tags)

        if tags.empty?
          data = tmap.values.map{|token| [token, "O"]}
        else
          data = []
          tags.keys.each_with_index do |loc, i|
            st = loc[0]
            ed = loc[1]

            tokens = tmap.select{|t|
              t[0].between?(st, ed) &&
                t[1].between?(st, ed)
            }.to_a

            # handle in betweens (should be tagged "O")
            if i > 0
              last = tags.keys[i-1]
              in_between = tmap.select do |t|
                t[0].between?(last[1], st) &&
                  t[1].between?(last[1], st)
              end
            else
              in_between = tmap.select do |t|
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

          tmap.keys.select{|k| k[1] > last_tag_loc[1] }.each do |loc|
            data << [tmap[loc], 'O']
          end

        end

        add_training_seq(data)
      end
    end
  end
end
