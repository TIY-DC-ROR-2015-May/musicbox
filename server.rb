require 'sinatra/base'

require 'pry'

class MusicBoxApp < Sinatra::Base
  enable :logging

  get "/sign_in" do
    erb :sign_in
  end

  post "/take_sign_in" do
    binding.pry
  end
end

MusicBoxApp.run!
