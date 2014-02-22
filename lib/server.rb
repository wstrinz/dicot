require 'sinatra'
require_relative 'dicot'

helpers do
  def label(string)
    Dicot.label(string)
  end
end

get '/label' do
  label(params[:message])
end
