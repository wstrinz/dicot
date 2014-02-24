ENV['RACK_ENV'] = 'test'

require_relative 'spec_helper'  # <-- your sinatra app
require_relative '../lib/server.rb'  # <-- your sinatra app
require 'rspec'
require 'rack/test'

describe 'Dicot Server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "runs" do
    get '/'
    expect(last_response).to be_ok
  end

  it "labels input" do
    get '/label?message=Where%27s%20Will%20(Tuesday%20morning)'

    expected = {"Will" => "Name", "Tuesday morning" => "TS"}
    expect(last_response.body).to eq expected.to_json
  end
end
