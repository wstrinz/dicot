
require_relative 'spec_helper.rb'

describe Dicot::Classify do
  let(:data) {[
    ["This is a test message", "test"],
    ["Some other sort of message?", "not-test"],
    ["Remind me to do a thing", "remind"]
  ]}

  describe ".train" do
    before do
      Dicot::Classify.reset!
    end

    it do
      data.each do |d|
        Dicot::Classify.train(*d)
      end

      data.each do |d|
        Dicot::Classify.classify(d[0]).should == d[1]
      end
    end

    it "isn't totally robust" do
      Dicot::Classify.train("What's up?", "chat")
    end
  end

  describe ".classify" do
    before do
      Dicot::Classify.reset!
      data.each do |d|
        Dicot::Classify.train(*d)
      end
    end

    it "works usually" do
      Dicot::Classify.classify("This is a test message").should == "test"
    end

    it "can classify repeated words" do
      Dicot::Classify.classify("Remind me to Remind").should == "remind"
    end
  end
end
