require 'httparty'
require 'json'

class SpotifyAPI
  # Token = File.read "./token"

  include HTTParty
  base_uri 'https://api.spotify.com'

  # default_options[:headers] = {
  #   "Authorization" => "token #{Token}",
  #   "User-Agent"    => "Wandows Explrer"
  # }

  def initialize
    #@headers = { "Authorization" => "token #{Token}", "User-Agent" => "Wandows Explorer" }
  end

  def get_track artist, track
    s = SpotifyAPI.get("/v1/search", query: { q: "artist:#{artist} + track:#{track}", type: "track"}) 
    # query: { q: "uprising", type: "track"}
    track_list = s["tracks"]["items"].map { |track| track.values_at("name", "uri") }
    track_list.first
  end
end

# require 'pry'
# spot = SpotifyAPI.new
# binding.pry
