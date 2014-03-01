require_relative 'spec_helper.rb'

describe Dicot::Features do
  before(:all) do
    train_on_fixtures
    enumerate_training_files
  end

  after(:all) do
    remove_fixtures
    remove_generated_training_files
  end

  describe ".raw_label" do
    it "should label a string" do
      Dicot::Features.raw_label("Hello I am a string").should_not be nil
    end

    it "correctly labels trained string" do
      str = "Where's Will (Friday morning)"
      Dicot::Features.raw_label(str).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
    end


    it 'identifies features in novel string' do
      str = "Where's Will (Ragnarok morning)"
      Dicot::Features.raw_label(str).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
    end
  end

  describe ".label" do
    it 'recognizes and extracts labels' do
      str = "Where's Will (Friday morning)"
      Dicot::Features.label(str).should ==
      [
        {string: "Will", tag: "Name", start: 8, end: 11},
        {string: "Friday morning", tag: "TS", start: 14, end: 27 }
      ]
    end

    it "gracefully handles things it doesn't understand" do
      str = "Test Input"
      Dicot::Features.label(str).should == []
    end


    describe "handling spaces" do
      before do
        save_training_text
        @str = "Weird token's?"
        @train = %w{O B-test I-test I-test}
        Dicot::Trainer.training_buffer << Dicot::Tokenizer.tokenize(@str).zip(@train)
        Dicot::Trainer.retrain
      end

      after do
        restore_training_text
        Dicot::Trainer.retrain
        restore_training_text
      end

      it 'handles tokens properly' do
        Dicot::Features.label(@str).should == [{ string: "token's?", tag: "test", start: 6, end: 13 }]
      end
    end
  end

  context "retraining" do
    before do
      save_training_text
    end

    after do
      restore_training_text
    end

    it "can be retrained" do
      str = "Bla Bla mostly arbitray text I wrote right here"
      untrained = %w{O O O O O O O O O}
      trained = %w{O O O O O O B-thing I-thing O}

      Dicot::Features.raw_label(str).first.map(&:last).should == untrained
      Dicot::Trainer.training_buffer << Dicot::Tokenizer.tokenize(str).zip(trained)
      Dicot.retrain

      Dicot::Features.raw_label(str).first.map(&:last).should == trained
    end

    it "still correctly labels known strings" do
      str1 = "Where's Will (Friday morning)"
      str2 = "Where's Will (on the Ragnarok morning)"
      trained = %w{O O B-Name O O O B-TS I-TS O}

      Dicot::Trainer.training_buffer << Dicot::Tokenizer.tokenize(str2).zip(trained)
      Dicot.retrain
      Dicot::Features.raw_label(str1).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
    end
  end

  describe "generates dummy model if none exists" do
    before { save_model }
    after { restore_model }

    it do
      File.delete 'model/model.mod'
      Dicot::Features.raw_label("anything should be O").first.map(&:last).should == %w{O O O O}
    end
  end

  describe 'training input' do
    describe 'arbitrary domain' do
      let(:string) { "yes no yes" }
      let(:tags) { { [0,2] => "arb", [7,9] => "arb" } }
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
        Dicot::Features.raw_label(string).first.should == expected
      end

      it "labels using new data" do
        Dicot::Features.label(string).should ==
        [
            {:string=>"yes", :tag=>"arb", :start=>0, :end=>2},
            {:string=>"yes", :tag=>"arb", :start=>7, :end=>9}
        ]
      end

      it "returns list of labels" do
        Dicot::Features.labels.should == ["Name", "TS", "arb"]
      end
    end
  end
end
