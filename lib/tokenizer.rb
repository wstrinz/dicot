
class Dicot
  class Tokenizer
    extend Treat::Core::DSL
    class << self
      def tokenize(string)
        e = entity string
        e.apply(:chunk, :tokenize)
        e.tokens.map(&:to_s)
      end
    end
  end
end
