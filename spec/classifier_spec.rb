
require_relative 'spec_helper.rb'

describe Dicot::Classify do
  let(:data) {["This is a test message", "test"]}
  let(:data2) {["Some other sort of message", "not-test"]}
  let(:data3) {["Remind me to do a thing", "remind"]}

  describe ".train" do
    it do
      Dicot::Classify.train(*data)
      Dicot::Classify.train(*data2)
      Dicot::Classify.train(*data3)
      Dicot::Classify.items.should == [data[0], data2[0], data3[0]]
    end
  end

  describe ".classify" do
    before do
      Dicot::Classify.train(*data)
      Dicot::Classify.train(*data2)
      Dicot::Classify.train(*data3)
    end

    it "works usually" do
      Dicot::Classify.classify("This is a test message").should == "test"
    end

    it "isn't very robust" do
      Dicot::Classify.classify("Remind me to Remind").should == "{error}"
    end
  end
end
