require_relative 'spec_helper.rb'

describe Dicot do
  it "should label a string" do
    Dicot.label("Hello I am a string").should_not be nil
  end

  it "correctly labels trained string" do
    str = "Where's Will (Friday morning)"
    Dicot.label(str).first.map(&:last).should == %w{O O O O B-TS I-TS O}
  end


  it 'identifies features in novel string' do
    str = "Where's Will (Ragnarok morning)"
    Dicot.label(str).first.map(&:last).should == %w{O O O O B-TS I-TS O}
  end

  it "isn't magic" do
    str = "Where's Will (on the Ragnarok morning)"
    Dicot.label(str).first.map(&:last).should == %w{O O O O O O O O O}
  end
end
