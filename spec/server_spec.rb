ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative 'spec_helper'
require_relative '../lib/server/server.rb'

describe 'Dicot Server' do
  include Rack::Test::Methods

  def app
    Dicot::Server
  end

  before(:all) do
    @feature_string = "Where's Will (Tuesday morning)"
    @feature_tags =
      [
        {string:"Will", tag: "Name", start: 8, end: 11},
        {string:"Tuesday morning", tag: "TS", start: 14, end: 28}
      ]

    @classify_string = "Where's Will? (Friday Morning)"
    @classify_expect = "Out of Office"

    @label_output =
    {
      string: @feature_string,
      tags: @feature_tags,
      class: @classify_expect
    }
  end

  describe "labels input" do
    it "get" do
      get '/label?data=Where%27s%20Will%20(Tuesday%20morning)'

      expect(last_response.body).to eq @label_output.to_json
    end

    it "post" do
      post '/label', data: @feature_string

      expect(last_response.body).to eq @label_output.to_json
    end
  end

  it "has training interface" do
    get '/train'
    expect(last_response).to be_ok
  end

  describe "classify" do
    let(:expected) {{ string: @classify_string, class: @classify_expect}}

    before(:all) do
      Dicot::Classify.train(@classify_string, @classify_expect)
    end

    it "get" do
      get "/classify?data=#{URI.escape(@classify_string)}"
      expect(last_response.body).to eq expected.to_json
    end

    it "post" do
      post "/classify", data: @classify_string
      expect(last_response.body).to eq expected.to_json
    end
  end

  describe "feedback queue" do
    let(:alt_queue) { [{string: "test1", tags: [{string: "test", start: 0, end: 3, tag: "test-tag"}] }] }

    before do
      Dicot::CRF.feedback_queue.clear
      Dicot.label(@feature_string)
    end

    after do
      Dicot::CRF.feedback_queue.clear
    end

    it "get" do
      get "/feedback_queue"
      expect(last_response.body).to eq [@label_output].to_json
    end

    it "update" do
      post "/update_feedback_queue", {data: alt_queue}
      expect(Dicot::CRF.feedback_queue).to eq alt_queue
    end

    it "empty update" do
      post "/update_feedback_queue", {data: []}
      expect(Dicot::CRF.feedback_queue).to eq []
    end
  end

  describe "submit to training queue" do
    let(:expected_training_queue) {[
      ["Where", "O"],
      ["'s", "O"],
      ["Will", "B-Name"],
      ["(", "O"],
      ["Tuesday", "B-TS"],
      ["morning", "I-TS"],
      [")", "O"]
    ]}

    let(:js_tags) {
      (0..(@feature_tags.size - 1)).to_a.each_with_object({}){|i,tags| tags[i] = @feature_tags[i] }
    }

    it do
      post "/add_sequence", {string: @feature_string, tags: js_tags}
      expect(Dicot::CRF.training_queue.last).to eq expected_training_queue
    end
  end

  describe "autocomplete word lists" do
    it "classes" do
      get "/list_classes"
      expect(last_response.body).to eq Dicot::Classify.classes.to_a.to_json
    end

    it "tags" do
      get "/list_tags"
      expect(last_response.body).to eq Dicot::Tag.labels.to_json
    end
  end
end
