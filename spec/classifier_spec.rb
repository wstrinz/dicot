
require_relative 'spec_helper.rb'

describe Dicot::Classifiers do
  let(:data) {[
    ["This is a test message", "test"],
    ["Some other sort of message?", "not-test"],
    ["Remind me to do a thing", "remind"]
  ]}

  describe ".train" do
    before do
      Dicot.model.classifier.reset!
    end

    it do
      data.each do |d|
        Dicot.model.classifier.train(d[0], d[1])
      end

      Dicot.model.classifier.retrain

      data.each do |d|
        Dicot.model.classifier.classify(d[0]).should == d[1]
      end
    end

    it "isn't totally robust" do
      Dicot.model.classifier.train("What's up?", "chat")
    end
  end

  describe ".classify" do
    before do
      Dicot.model.classifier.reset!
      data.each do |d|
        Dicot.model.classifier.train(*d)
      end

      Dicot.model.classifier.retrain
    end

    it "works usually" do
      Dicot.model.classifier.classify("This is a test message").should == "test"
    end

    it "can classify repeated words" do
      Dicot.model.classifier.classify("Remind me to Remind").should == "remind"
    end
  end
end
