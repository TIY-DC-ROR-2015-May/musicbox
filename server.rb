require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning

require 'omniauth'
require 'omniauth-spotify'

require 'pry'

require './db/setup'
require './lib/all'

class MusicBoxApp < Sinatra::Base
  enable :logging
  enable :sessions

  use OmniAuth::Builder do
    secret_token_path = File.expand_path("../spotify-token", __FILE__)
    secret_token      = File.read(secret_token_path).strip
    provider :spotify, "db59dd82abf948b7b3be60daa998c4f3", secret_token
  end

  def current_user
    if session[:logged_in_user_id]
      User.find session[:logged_in_user_id]
    #else
    #  nil
    end
  end

  get "/sign_in" do
    erb :sign_in
  end

  post "/take_sign_in" do
    user = User.where(
      name:     params[:username],
      password: params[:password]
    ).first

    if user
      session[:logged_in_user_id] = user.id
      redirect to("/")
    else
      @message = "Bad username or password"
      #redirect to("/sign_in")
      erb :sign_in
    end
  end

  get "/auth/:name/callback" do
    auth = request.env["omniauth.auth"]
    raise "What should we do here ...?"
  end

  get "/" do
    erb :home
  end
end

MusicBoxApp.run! if $PROGRAM_NAME == __FILE__
