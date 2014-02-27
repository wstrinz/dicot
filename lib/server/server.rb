require 'sinatra'
require 'json'
require_relative '../dicot'

helpers do
  def label(string)
    Dicot.label(string)
  end

  def classify(string)
    {string: string, class: Dicot.classify(string)}
  end

  def retrain
    Dicot.retrain
  end

  def add_sequence(data)
    data = Array(data)
    tags = data["tags"].each_with_object({}) do |tag, h|
      h[ [tag["start"], tag["end"]] ] = tag["tag"]
    end

    Dicot.train(data["string"], tags)
  end
end

get '/' do
  haml :index
end

get '/label' do
  content_type :json
  label(params[:data]).to_json
end

post '/label' do
  content_type :json
  label(params[:data]).to_json
end

get '/classify' do
  content_type :json
  classify(params[:data]).to_json
end

post '/classify' do
  content_type :json
  classify(params[:data]).to_json
end

get '/retrain' do
  retrain
  "Retrain successful"
end

get '/train' do
  haml :train
end

get '/add_sequence' do
  add_sequence JSON.parse(params[:data])
  "sequence added"
end

post '/add_sequence' do
  add_sequence JSON.parse(params[:data])
  "sequence added"
end
