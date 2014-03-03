begin
  require 'treat'
  $use_treat = true
rescue LoadError
  require 'gtokenizer'
  $use_treat = false
end

class Dicot
  class Tokenizer
    if $use_treat
      extend Treat::Core::DSL
      class << self
        def tokenize(string)
          e = entity string
          e.apply(:chunk, :tokenize)
          e.tokens.map(&:to_s)
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
