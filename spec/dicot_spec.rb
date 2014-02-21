require_relative 'spec_helper.rb'

describe Dicot do
  it "should label a string" do
    Dicot.label("Hello I am a string").should_not be nil
  end
end
