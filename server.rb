require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning

require 'pry'

require './db/setup'
require './lib/all'

class MusicBoxApp < Sinatra::Base
  enable :logging
  enable :method_override
  enable :sessions

  set :session_secret, File.read("./session_secret.txt")

  def current_user
    if session[:logged_in_user_id]
      User.find session[:logged_in_user_id]
    #else
    #  nil
    end
  end

  def set_message message
    session[:flash_message] = message
  end

  def get_message
    session.delete(:flash_message)
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
      set_message "Bad username or password"
      redirect to("/sign_in")
    end
  end

  get "/" do
    @songs = Song.all
    erb :home
  end

  post "/suggest_song" do
    # enter Artist, Title, Album=nil
    # submit and save to Songs table
    # require_current_user
    if current_user.num_of_songs_suggested_this_week <= 4 
      song = Song.where(
        artist:             params[:artist],
        title:               params[:title],
        suggester_id:   current_user.id
      ).first_or_create!
    else
      set_message "You have submitted too many songs this week. Try again later."
    end
    redirect to("/")
  end

  delete "/sign_out" do
    if current_user
      session.delete(:logged_in_user_id)
      redirect to ("/")
    end
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

  get "/change_password" do
    @password = current_user.password
    @username = current_user.name
    erb :change_password
  end

  post "/update_password" do
    current_user.update(password: params["new_password"])
    redirect to("/change_password")
  end

  post "/update_username" do
    current_user.update(name: params["new_username"])
    redirect to("/change_password")
  end
end

MusicBoxApp.run! if $PROGRAM_NAME == __FILE__
