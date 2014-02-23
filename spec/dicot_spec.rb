require_relative 'spec_helper.rb'

describe Dicot do
  before(:all) do
    Dicot::Trainer.retrain('spec/fixtures/train.txt')
    if File.exist? 'model/train.txt'
      FileUtils.copy 'model/train.txt', 'model/train.txt.bak'
    end

    FileUtils.copy 'spec/fixtures/train.txt', 'model/train.txt'
  end

  after(:all) do
    if File.exist? 'model/train.txt.bak'
      FileUtils.copy 'model/train.txt.bak', 'model/train.txt'
      FileUtils.rm 'model/train.txt.bak'
    end
  end

  it "should label a string" do
    Dicot.raw_label("Hello I am a string").should_not be nil
  end

  it "correctly labels trained string" do
    str = "Where's Will (Friday morning)"
    Dicot.raw_label(str).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
  end


  it 'identifies features in novel string' do
    str = "Where's Will (Ragnarok morning)"
    Dicot.raw_label(str).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
  end

  it 'recognizes and extracts labels' do
    str = "Where's Will (Friday morning)"
    Dicot.label(str).should == { "Will" => "Name", "Friday morning" => "TS" }
  end

  context "retraining" do
    before do
      @original_training_text = IO.read('model/train.txt')
    end

    after do
      open('model/train.txt','w'){|f| f.write @original_training_text}
    end

    it "can be retrained" do
      str = "Bla Bla mostly arbitray text I wrote right here"
      untrained = %w{O O O O O O O O O}
      trained = %w{O O O O O O B-thing I-thing O}

      Dicot.raw_label(str).first.map(&:last).should == untrained
      Dicot::Trainer.training_buffer << Dicot::Tokenizer.tokenize(str).zip(trained)
      Dicot.retrain

      Dicot.raw_label(str).first.map(&:last).should == trained
    end

    it "still correctly labels known strings" do
      str1 = "Where's Will (Friday morning)"
      str2 = "Where's Will (on the Ragnarok morning)"
      trained = %w{O O B-Name O O O B-TS I-TS O}

      Dicot::Trainer.training_buffer << Dicot::Tokenizer.tokenize(str2).zip(trained)
      Dicot.retrain
      Dicot.raw_label(str1).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
    end
  end

  describe "generates dummy model if none exists" do
    before { @original_model = IO.read('model/model.mod') }
    after { open('model/model.mod','w'){|f| f.write @original_model} }

    it do
      File.delete 'model/model.mod'
      Dicot.raw_label("anything should be O").first.map(&:last).should == %w{O O O O}
    end
  end

  describe 'training input' do
    describe 'test domain' do
      let(:string) { "Where's Somebody? (Wednesday Afternoon)"  }
      let(:tags) { {[19, 27] => "B-TS", [28,36] => "I-TS" }  }
      let(:expected) { [["Where", "O"], ["'s", "O"], ["Somebody", "O"], ["?", "O"], ["(", "O"], ["Wednesday", "B-TS"], ["Afternoon", "I-TS"], [")", "O"]]}

      it "parses tags and adds to training buffer" do
        Dicot.train(string, tags)
        Dicot::Trainer.training_buffer.last.should == expected
      end
    end

    describe 'arbitrary domain' do
      let(:string) { "yes no yes" }
      let(:tags) { { [0,2] => "B-arb", [7,9] => "B-arb" } }
      let(:expected) { [["yes", "B-arb"],["no","O"],["yes","B-arb"]] }

      before(:all) do
        @original_training_text = IO.read('model/train.txt')
      end

      after(:all) do
        open('model/train.txt','w'){|f| f.write @original_training_text}
      end

      it "adds to training buffer" do
        Dicot.train(string, tags)
        Dicot::Trainer.training_buffer.last.should == expected
      end

      it "retrains using new data" do
        Dicot::Trainer.retrain
        Dicot.raw_label(string).first.should == expected
      end
    end
  end
end
