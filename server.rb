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

  post "/suggest_song" do
    # enter Artist, Title, Album=nil
    # submit and save to Songs table
    song = Song.where(
      artist: params[:artist],
      title: params[:title],
      suggester_id: current_user.id
      ).first_or_create!

    if song
      # if current_user.id submits more than 2 songs/day (testing purposes)
      # sends @message = "You've submitted too many songs this week. Try again next time."
    else
      # save song
      # redirect to ("/")
      erb :home
    end
  end
end

MusicBoxApp.run! if $PROGRAM_NAME == __FILE__