
require_relative 'spec_helper.rb'

describe Dicot::Classify do

  let(:data) {["This is a test message", "test"]}
  let(:data2) {["Some other sort of message", "not-test"]}

  describe ".train" do
    it do
      Dicot::Classify.train(*data)
      Dicot::Classify.train(*data2)
      Dicot::Classify.items.should == [data[0], data2[0]]
    end
  end

  describe ".classify" do
    before do
      Dicot::Classify.train(*data)
      Dicot::Classify.train(*data2)
    end

    it do
      Dicot::Classify.classify("This is a test message").should == "test"
    end
  end
end
