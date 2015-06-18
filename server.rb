require 'sinatra/base'
require 'tilt/erubis' # Fixes a warning
require 'rack/cors'
require 'pry'
require './db/setup'
require './lib/all'
require './spotify_api'

class MusicBoxApp < Sinatra::Base
  enable :logging
  enable :method_override
  enable :sessions

  set :session_secret, (ENV["SESSION_SECRET"] || "development")

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: :get
    end
  end

  after do
    ActiveRecord::Base.connection.close
  end

  def current_user
    if session[:logged_in_user_id]
      User.find session[:logged_in_user_id]
    #else
    #  nil
    end
  end

  def require_user
  	unless current_user
      set_message "You need to log in to see this page"
      redirect to ("/sign_in")
    end
  end

  def set_message message
    session[:flash_message] = message
  end

  def get_message
    session.delete(:flash_message)
  end

  def admin_set_message message
    set_message message
  end

  def admin_get_message
    get_message
  end

  get "/sign_in" do
    erb :sign_in
  end

  post "/take_sign_in" do
    user = User.where(
      name:     params[:username],
      password: User.encrypt_password(params[:password])
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
    require_user
    spot = SpotifyAPI.new
    spot_track = spot.get_track params[:artist], params[:title]
    if spot_track
      uri = spot_track[1]
      if current_user.num_of_songs_suggested_this_week <= 4 
        song = Song.where(
          artist:       params[:artist],
          title:        params[:title],
          suggester_id: current_user.id,
          uri:          uri
        ).first_or_create!
        current_user.votes.create! song: song, value: 1
      else
        set_message "You have submitted too many songs this week. Try again later."
      end
    else
      set_message "No song found, please try again."
    end
    redirect to("/")
  end

  # post "/get_song"
  #   spot = SpotifyAPI.new
  #   spot.get_track params[:artist], params[:title]
  # end

  delete "/sign_out" do
  	require_user
    if current_user
      session.delete(:logged_in_user_id)
      redirect to ("/")
    end
  end

  post "/vote" do
  	require_user
    #TODO - What if there are two artists with same song title?
    if current_user.votes_left > 0
      song = Song.find_by_title(params[:song_title])
      # current_user.votes.create! song_id: song_id, value: params[:value]
      Vote.create! voter_id: current_user.id, song_id: song.id, value: params[:value]
      vl = current_user.votes_left
      current_user.update(votes_left: vl -= 1)
    else
      set_message "You are out of votes!"
      status 400
    end
    redirect to ("/")
  end

  post "/playlist" do
    @playlist = Playlist.create!
    Song.by_sort_letter.each do |letter, songs|
      next unless songs
      winner = songs.max_by { |s| s.total_votes }
      @playlist.songs << winner
    end
    erb :show_playlist
  end

  get "/playlist" do
    @playlist = Playlist.order(created_at: :asc).last
    erb :show_playlist
  end

  get "/about_song/:id" do
    require_user
    @song = Song.find(params[:id])
    erb :song
  end

  get "/change_password" do
  	require_user
    @password = current_user.password
    @username = current_user.name
    @votes_left = current_user.votes_left
    @admin = current_user.admin
    @user_votes = current_user.votes
    erb :change_password
  end

  post "/update_password" do
  	require_user
    current_user.update(password: params["new_password"])
    redirect to("/change_password")
  end

  post "/update_username" do
  	require_user
    current_user.update(name: params["new_username"])
    redirect to("/change_password")
  end

  get "/admin_dashboard" do
  	require_user
    erb :admin_dashboard
  end

  patch "/delete_user" do
  	require_user
    if current_user.admin?
      deleted_user = User.find_by_name(params[:name])
      deleted_user.destroy
      admin_set_message "#{deleted_user.name} has been deleted."
    end
    redirect to("/admin_dashboard")
  end

  post "/invite_user" do
  	require_user
    if current_user.admin?
      new_user = User.create name: params[:name], password: params[:password]
        if new_user.persisted?
          admin_set_message "User account has been created. The temporary password is #{params[:password]}."
        else
          admin_set_message "A user with this name already exists."
        end
    end
    redirect to("/admin_dashboard")
  end

  patch "/assign_admin" do
  	require_user
    if current_user.admin?
      new_admin = User.find_by_name(params[:name])
      if new_admin
        new_admin.update(admin: true)
        admin_set_message "#{new_admin.name} now has admin privileges."
      end
    end
    redirect to("/admin_dashboard")
  end

  patch "/revoke_admin" do
  	require_user
    if current_user.admin?
      revoked_admin = User.find_by_name(params[:name])
      revoked_admin.update(admin: false)
    end
    redirect to("/admin_dashboard")
  end

  get "/songs/:letter" do
    results = []

    Song.all.each do |song|
      if song.title.downcase.start_with? params[:letter].downcase
        song_as_hash = {
          artist:       song.artist,
          title:        song.title,
          vote_count:   song.total_votes,
          spotify_uri:  song.uri,
          suggested_by: song.suggester.name
        }

        results.push song_as_hash
      end
    end

    sorted_results = results.sort_by { |h| h[:vote_count] }
    unless params[:sort].to_s.downcase == "asc"
      sorted_results.reverse!
    end

    # results = [
    #   { artist: "ASDf", title: "aksjdnfa", vote_count: 2 },
    #   { artist: "nsk", title: "asjdnf", vote_count: 3 }
    # ]
    return sorted_results.to_json
  end
end

MusicBoxApp.run! if $PROGRAM_NAME == __FILE__
