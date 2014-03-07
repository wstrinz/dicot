begin
  require 'treat'
  $use_treat = true
rescue LoadError
  $use_treat = false
end

require 'gtokenizer'

class Dicot
  class Tokenizer
    if $use_treat
      extend Treat::Core::DSL
      class << self
        def tokenize(string)
          e = entity string
          e.apply(:chunk, :tokenize)

          if e.tokens.empty?
            GTokenizer.parse(string)
          else
            e.tokens.map(&:to_s)
          end
        end
      end
    else
      class << self
        def tokenize(string)
          GTokenizer.parse(string)
        end
      end
    end
  end
end
