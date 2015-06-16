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
    #TODO - What if there are two artists with same song title?
    if current_user.votes_left > 0
      song = Song.find_by_title(params[:song_title])
      # current_user.votes.create! song_id: song_id, value: params[:value]
      Vote.create! voter_id: current_user.id, song_id: song.id, value: params[:value]
    else
      status 400
      body "You have exceeded your weekly vote limit!"
    end
  end
end

MusicBoxApp.run! if $PROGRAM_NAME == __FILE__