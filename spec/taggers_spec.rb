
require_relative 'spec_helper.rb'

taggers = [:crf]

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
      let(:test_str) { "Test Input" }
      let(:test_expectation){[
        {string: "Test", tag: "test", start: 0, end: 3},
        {string: "Input", tag: "data", start: 5, end: 9}
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

      it "learns" do
        subject.train(test_str, subject.tag_coordinates(test_expectation))
        subject.retrain
        subject.label(test_str).should == test_expectation
      end
    end
  end
end

