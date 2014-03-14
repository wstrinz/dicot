
require_relative 'spec_helper.rb'

describe "Dicot Workers" do
  taggers = [:crf]
  classifiers = [:stuff]

  describe "Tagger" do
    taggers.each do |tagger|
      describe tagger do
        let(:model) { Dicot::Model.new(tag: tagger) }
        subject { model.tagger }

        let(:str) { "Where's Will (Friday morning)" }
        let(:expected) {[
          {string: "Will", tag: "Name", start: 8, end: 11},
          {string: "Friday morning", tag: "TS", start: 14, end: 27 }
        ]}

        it 'recognizes and extracts labels' do
          subject.label(str).should == expected
        end

        it "gracefully handles things it doesn't understand" do
          test_str = "Test Input"
          subject.label(test_str).should == []
        end

        it "receives training input" do
          subject.train(str, subject.tag_coordinates(expected)).should_not == nil
        end
      end
    end
  end

  describe "Classifier" do
    classifiers.each do |classifier|
      let(:model) { Dicot::Model.new(classify: classifier) }
      subject { model.classifier }

      let(:str) { "Where's Will (Friday morning)" }
      let(:expected) { "Out of Office" }
      let(:data) {[
        ["This is a test message", "test"],
        ["Some other sort of message?", "not-test"],
        ["Remind me to do a thing", "remind"]
      ]}

      describe classifier do
        describe "#train" do
          before do
            subject.reset!
          end

          it do
            data.each do |d|
              subject.train(d[0], d[1])
            end

            subject.retrain

            data.each do |d|
              subject.classify(d[0]).should == d[1]
            end
          end

          it "isn't totally robust" do
            subject.train("What's up?", "chat")
          end
        end

        describe "#classify" do
          before do
            subject.reset!
            data.each do |d|
              subject.train(*d)
            end

            subject.retrain
          end

          it "works usually" do
            subject.classify("This is a test message").should == "test"
          end

          it "can classify repeated words" do
            subject.classify("Remind me to Remind").should == "remind"
          end
        end
      end
    end
  end
end
