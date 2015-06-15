require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning

require 'pry'

require './db/setup'
require './lib/all'

class MusicBoxApp < Sinatra::Base
  enable :logging
  enable :sessions

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

  get "/" do
    erb :home
  end

  post "/vote" do
    song_id = Song.where(title: params[:song_title]).first.id
    song = Song.where(title: params[:song_title]).first
    Vote.create! voter_id: current_user.id, song_id: song_id, value: params[:value]
  end
end

MusicBoxApp.run! if $PROGRAM_NAME == __FILE__