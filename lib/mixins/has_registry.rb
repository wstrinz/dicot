class Dicot
  module HasRegistry
    def for(symbol)
      registry.fetch(symbol)
    end

    def registry
      @registry ||= {}
    end
  end
end
