require_relative 'spec_helper.rb'

describe Dicot do

  describe ".label" do
    it 'recognizes and extracts labels' do
      str = "Where's Will (Friday morning)"
      Dicot.label(str).should ==
      {
        string: str,
        tags: [
          {string: "Will", tag: "Name", start: 8, end: 11},
          {string: "Friday morning", tag: "TS", start: 14, end: 27 }
        ],
        class: "Out of Office"
      }
    end
  end

  describe 'feedback queue' do
    before do
      Dicot::CRF.feedback_queue.clear
    end

    it 'adds all labeled strings by default' do
      str = "Where's Will (Friday morning)"
      Dicot.label(str)
      Dicot::CRF.feedback_queue.last.should ==
      {
        string: str,
        tags:
        [
          {string: "Will", tag: "Name", start: 8, end: 11},
          {string: "Friday morning", tag: "TS", start: 14, end: 27 }
        ],
        class: "Out of Office"
      }
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
      str = "Bla Bla mostly arbitray text I yellow banana here"
      trained = %w{O O O O O O B-unexpected I-unexpected O}

      Dicot::Tag.raw_label(str).first.map(&:last).should_not == trained
      Dicot::CRF.training_queue << Dicot::Tokenizer.tokenize(str).zip(trained)
      Dicot.retrain

      Dicot::Tag.raw_label(str).first.map(&:last).should == trained
    end
  end

  describe 'training input' do
    let(:string) { "yes no yes" }
    let(:tags) { { [0,2] => "arb", [7,9] => "arb" } }
    let(:expected) { [["yes", "B-arb"],["no","O"],["yes","B-arb"]] }

    before(:all) do
      @original_training_text = IO.read('model/train.txt')
    end

    after(:all) do
      open('model/train.txt','w'){|f| f.write @original_training_text}
    end

    it "adds to training queue" do
      Dicot.train(string, tags)
      Dicot::CRF.training_queue.last.should == expected
    end

    it "retrains using new data" do
      Dicot::CRF.retrain
      Dicot::Tag.raw_label(string).first.should == expected
    end

    it "labels using new data" do
      Dicot.label(string).should ==
      {
        string: string,
        tags: [
          {:string=>"yes", :tag=>"arb", :start=>0, :end=>2},
          {:string=>"yes", :tag=>"arb", :start=>7, :end=>9}
        ],
        class: "test"
      }
    end
  end
end
