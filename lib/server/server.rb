require 'sinatra/base'
require 'haml'
require 'json'
require_relative '../dicot'

class Dicot
  class Server < Sinatra::Base
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
        tags = data["tags"].each_with_object({}) do |tag, h|
          h[ [tag["start"].to_i, tag["end"].to_i] ] = tag["tag"]
        end

        Dicot.train(data["string"], tags)
      end

      def feedback_queue
        Dicot.feedback_queue.to_json
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

    post '/add_sequence' do
      add_sequence params[:data]
      "sequence added"
    end

    get '/feedback_queue' do
      content_type :json
      feedback_queue
    end

    run! if app_file == $0
  end
end
