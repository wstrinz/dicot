require_relative 'spec_helper.rb'

describe Dicot do

  describe ".label" do
    it 'recognizes and extracts labels' do
      str = "Where's Will (Friday morning)"
      Dicot.label(str).should ==
      [
        {string: "Will", tag: "Name", start: 8, end: 11},
        {string: "Friday morning", tag: "TS", start: 14, end: 27 }
      ]
    end

    describe 'feedback queue' do
      it 'adds all labeled strings by default' do
        str = "Where's Will (Friday morning)"
        Dicot.label(str)
        Dicot::Trainer.feedback_queue.last.should ==
        {
          message: str,
          tags:
          [
            {string: "Will", tag: "Name", start: 8, end: 11},
            {string: "Friday morning", tag: "TS", start: 14, end: 27 }
          ]
        }
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
        Dicot.label(string).should ==
        [
          {:string=>"yes", :tag=>"arb", :start=>0, :end=>2},
          {:string=>"yes", :tag=>"arb", :start=>7, :end=>9}
        ]
      end
    end
  end
end
