require_relative 'spec_helper.rb'

describe Dicot do
  it "should label a string" do
    Dicot.label("Hello I am a string").should_not be nil
  end

  it "correctly labels trained string" do
    str = "Where's Will (Friday morning)"
    Dicot.label(str).first.map(&:last).should == %w{O O O O B-TS I-TS O}
  end


  it 'identifies features in novel string' do
    str = "Where's Will (Ragnarok morning)"
    Dicot.label(str).first.map(&:last).should == %w{O O O O B-TS I-TS O}
  end

  context "retraining" do
    before(:each) do
      @original_training_text = IO.read('model/train.txt')
    end

    after(:each) do
      open('model/train.txt','w'){|f| f.write @original_training_text}
    end

    it "can be retrained" do
      str = "Where's Will (on the Ragnarok morning)"
      untrained = %w{O O O O O O O O O}
      trained = %w{O O O O O O B-TS I-TS O}

      Dicot.label(str).first.map(&:last).should == untrained

      Dicot::Trainer.retrain(Dicot::Tokenizer.tokenize(str).zip(trained))

      Dicot.label(str).first.map(&:last).should == trained
    end

    it "still correctly labels known strings" do
      str1 = "Where's Will (Friday morning)"
      str2 = "Where's Will (on the Ragnarok morning)"
      trained = %w{O O O O O O B-TS I-TS O}

      Dicot::Trainer.retrain(Dicot::Tokenizer.tokenize(str2).zip(trained))
      Dicot.label(str1).first.map(&:last).should == %w{O O O O B-TS I-TS O}
    end
  end
end
