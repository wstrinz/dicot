begin
  require 'treat'
  $use_treat = true
rescue LoadError
  $use_treat = false
end

require 'gtokenizer'

class Dicot
  class Tokenize
    class << self
      def for(symbol)
        Tokenizers::Base
      end
    end
  end
end

class Dicot
  class Tokenizers
    class Base
      def initialize(model)

      end

      def token_map(string)
        copy = string.clone
        map = {}
        pos = 0
        tokenize(string).each do |token|
          start = pos + copy.index(token)
          ed = start + token.length - 1
          map[[start, ed]] = string[start..ed]
          pos = ed + 1
          copy = string[pos..-1]
        end

        map
      end

      if $use_treat
        include Treat::Core::DSL
        def tokenize(string)
          e = entity string
          e.apply(:chunk, :tokenize)

          if e.tokens.empty?
            GTokenizer.parse(string)
          else
            e.tokens.map(&:to_s)
          end
        end

      else
        def tokenize(string)
          GTokenizer.parse(string)
        end
      end
    end
  end
end
