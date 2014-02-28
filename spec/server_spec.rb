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
    @classify_expect = "Out of office"
  end

  describe "labels input" do
    it "get" do
      get '/label?data=Where%27s%20Will%20(Tuesday%20morning)'

      expect(last_response.body).to eq @feature_tags.to_json
    end

    it "post" do
      post '/label', data: @feature_string

      expect(last_response.body).to eq @feature_tags.to_json
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
    before do
      Dicot::Trainer.feedback_queue.clear
      Dicot.label(@feature_string)
    end

    it do
      get "/feedback_queue"
      expect(last_response.body).to eq [{string: @feature_string, tags: @feature_tags}]
    end
  end
end
