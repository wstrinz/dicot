class Dicot
  class Model
    attr :tokenizer, :classifier, :tagger, :name, :surpress_warnings

    def initialize(name: "default", tokenizer: :treat, classify: :stuff, tag: :crf, surpress_warnings: false)
      @name = name
      @tokenizer = Tokenize.for(tokenizer).new(self)
      @classifier = Classify.for(classify).new(self)
      @tagger = Tag.for(tag).new(self)
      @surpress_warnings = surpress_warnings
    end

    def save
      classifier.save
      tagger.save
    end

    def load
      classifier.load
      tagger.load
    end

    def train(string, tags, klass)
      tagger.train(string, tags)
      classifier.train(string, klass) if klass
    end

    def retrain
      tagger.retrain
      classifier.retrain
    end

    def model_dir
      'model'
    end

    def tokenize(string)
      tokenizer.tokenize(string)
    end

    def classify(string)
      classifier.classify(string)
    end

    # TODO Rename this to features
    def label(string)
      tagger.label(string)
    end

    def training_base_path
      File.join(model_dir, "train")
    end

    def model_base_path
      File.join(model_dir, name)
    end

    def model_full_path
      File.join(model_base_path, ".mod")
    end
  end
end
