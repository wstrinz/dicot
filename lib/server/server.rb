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
        Dicot::CRF.save
      end

      def add_sequence(data)
        data["tags"] ||= {}
        tags = data["tags"].values.each_with_object({}) do |tag, h|
          h[ [tag["start"].to_i, tag["end"].to_i] ] = tag["tag"]
        end

        Dicot.train(data["string"], tags, data["class"])
      end

      def feedback_queue
        Dicot.feedback_queue.to_json
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) { |ent,h|
          h[ent[0].to_sym] = ent[1]
        }
      end

      def update_feedback_queue(new_queue)
        new_queue = [] if new_queue == nil
        new_queue = new_queue.values if new_queue.is_a? Hash
        new_queue = new_queue.map{|entry|
          if entry["tags"]
            entry["tags"] = entry["tags"].values if entry["tags"].is_a? Hash
            entry["tags"] = entry["tags"].map do |ent|
              ent["start"] = ent["start"].to_i
              ent["end"] = ent["end"].to_i
              symbolize_keys(ent)
            end
          end

          symbolize_keys(entry)
        }

        Dicot::CRF.feedback_queue = new_queue
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
      add_sequence params
      "sequence added"
    end

    post '/add_classification' do
      add_classification params
    end

    get '/feedback_queue' do
      content_type :json
      feedback_queue
    end

    post '/update_feedback_queue' do
      content_type :json
      update_feedback_queue params[:data]
      {head: :no_content}
    end

    get '/list_tags' do
      content_type :json
      Dicot::Tag.labels.to_json
    end

    get '/list_classes' do
      content_type :json
      Dicot::Classify.classes.to_a.to_json
    end

    run! if app_file == $0
  end
end
