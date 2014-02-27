ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative 'spec_helper'
require_relative '../lib/server/server.rb'

describe 'Dicot Server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "labels input" do
    it "get" do
      get '/label?data=Where%27s%20Will%20(Tuesday%20morning)'

      expected =
      [
        {string:"Will", tag: "Name", start: 8, end: 11},
        {string:"Tuesday morning", tag: "TS", start: 14, end: 28}
      ]
      expect(last_response.body).to eq expected.to_json
    end

    it "post" do
      post '/label', data: "Where's Will (Tuesday morning)"

      expected =
      [
        {string:"Will", tag: "Name", start: 8, end: 11},
        {string:"Tuesday morning", tag: "TS", start: 14, end: 28}
      ]
      expect(last_response.body).to eq expected.to_json
    end
  end

  it "has training interface" do
    get '/train'
    expect(last_response).to be_ok
  end

  describe "classify" do
    before(:all) do
      @string = "Where's Will? (Friday Morning)"
      klass = "Out of office"

      Dicot::Classify.train(@string, klass)
      @expected = { string: @string, class: klass }
    end

    it "get" do
      get "/classify?data=#{URI.escape(@string)}"
      expect(last_response.body).to eq @expected.to_json
    end

    it "post" do
      post "/classify", data: @string
      expect(last_response.body).to eq @expected.to_json
    end
  end
end
