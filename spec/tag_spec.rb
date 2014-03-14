require_relative 'spec_helper.rb'

describe Dicot::Tag do
  subject { Dicot.model.tagger }

  describe ".raw_label" do
    it "should label a string" do
      subject.raw_label("Hello I am a string").should_not be nil
    end

    it "correctly labels trained string" do
      str = "Where's Will (Friday morning)"
      subject.raw_label(str).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
    end


    it 'identifies features in novel string' do
      str = "Where's Will (Ragnarok morning)"
      subject.raw_label(str).first.map(&:last).should == %w{O O B-Name O B-TS I-TS O}
    end

    it 'respects feature boundaries' do
      str = "Where's Will this afternoon"
      subject.raw_label(str).first.map(&:last).should == %w{O O B-Name B-TS I-TS}
    end
  end

  describe ".label" do
    it 'recognizes and extracts labels' do
      str = "Where's Will (Friday morning)"
      subject.label(str).should ==
      [
        {string: "Will", tag: "Name", start: 8, end: 11},
        {string: "Friday morning", tag: "TS", start: 14, end: 27 }
      ]
    end

    it "gracefully handles things it doesn't understand" do
      str = "Test Input"
      subject.label(str).should == []
    end


    describe "handling spaces" do
      before do
        save_training_text
        @str = "Weird token's?"
        @train = %w{O B-test I-test I-test}
        Dicot.model.tagger.training_queue << Dicot.model.tokenizer.tokenize(@str).zip(@train)
        Dicot.model.tagger.retrain
      end

      after do
        restore_training_text
        Dicot.model.tagger.retrain
        restore_training_text
      end

      it 'handles tokens properly' do
        subject.label(@str).should == [{ string: "token's?", tag: "test", start: 6, end: 13 }]
      end
    end
  end

  # TODO create tokenizer spec
  describe '.token_map' do
    let(:string) { "Please remind me to remind them" }
    let(:map) { {
      [0,5] => 'Please',
      [7,12] => 'remind',
      [14,15] => 'me',
      [17,18] => 'to',
      [20,25] => 'remind',
      [27,30] => 'them'
    } }

    it 'returns a hash of token positions' do
      Dicot.model.tokenizer.token_map(string).should == map
    end
  end

  context "retraining" do
    let(:model) { Dicot::Model.new(name: 'test-retrain') }

    it "can be retrained" do
      str = "Bla Bla mostly arbitray text I wrote right here"
      untrained = %w{O O O O O O O O O}
      trained = %w{O O O O O O B-thing I-thing O}

      model.tagger.raw_label(str).first.map(&:last).should == untrained
      model.tagger.training_queue << model.tokenizer.tokenize(str).zip(trained)
      model.tagger.retrain

      model.tagger.raw_label(str).first.map(&:last).should == trained
    end

    it "still correctly labels known strings" do
      str1 = "Where's Will (Friday morning)"
      str2 = "Where's Will (on the Ragnarok morning)"
      trained = %w{O O B-Name O O O B-TS I-TS O}

      model.tagger.training_queue << model.tokenizer.tokenize(str2).zip(trained)
      model.tagger.retrain
      model.tagger.raw_label(str1).first.map(&:last).should == %w{O O B-Name O O O O}
    end
  end

  describe "generates dummy model if none exists" do
    let(:empty_model) { Dicot::Model.new(name: 'empty_model') }

    it do
      empty_model.tagger.raw_label("anything should be O").first.map(&:last).should == %w{O O O O}
    end
  end

  describe 'training input' do
    describe 'arbitrary domain' do
      let(:string) { "yes no yes" }
      let(:tags) { { [0,2] => "arb", [7,9] => "arb" } }
      let(:expected) { [["yes", "B-arb"],["no","O"],["yes","B-arb"]] }

      before(:all) do
        @model = Dicot::Model.new(name: 'test-arb')
      end

      it "adds to training queue" do
        @model.tagger.train(string, tags)
        @model.tagger.training_queue.last.should == expected
      end

      it "retrains using new data" do
        @model.tagger.retrain
        @model.tagger.raw_label(string).first.should == expected
      end

      it "labels using new data" do
        @model.tagger.label(string).should ==
        [
            {:string=>"yes", :tag=>"arb", :start=>0, :end=>2},
            {:string=>"yes", :tag=>"arb", :start=>7, :end=>9}
        ]
      end

      it "returns list of labels" do
        @model.tagger.labels.should == ["arb"]
      end
    end

    describe "input order" do
      let(:string) { "Place - Time and Manner" }
      let(:tags) { { [8,11] => "T", [0,4] => "P", [17,22] => "M" } }
      let(:expected) { [["Place", "B-P"],["-","O"],["Time","B-T"],["and","O"],["Manner","B-M"]] }

      after do
        Dicot.model.tagger.training_queue.clear
      end

      it "reorders input tags properly" do
        Dicot.train(string, tags)
        Dicot.model.tagger.training_queue.last.should == expected
      end
    end

    describe "special characters" do
      let(:input_string) { "Banzo - Carts will NOT be open today :(  Stupid #polarvortex " }
      let(:wrong_tags) { [{:string=>"Stupid#", :tag=>"TS", :start=>40, :end=>46}] }

      before(:all) do
        @model = Dicot::Model.new(name: "test-special")
      end

      it "sees the wrong tags before retraining" do
        @model.label(input_string).should == wrong_tags
      end
    end
  end
end
