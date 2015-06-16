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

  # def org_members org_name=nil
  #   # unless org_name
  #   #   org_name = class_org
  #   # end
  #   org_name ||= class_org
  #   # self.class.get ...
  #   GithubAPI.get("/orgs/#{org_name}/members")
  # end

  def repos page=nil, user=nil
    page ||= 1
    user ||= "jamesdabbs"
    # GET /users/jamesdabbs/repos
    SpotifyAPI.get("/users/#{user}/repos", query: { page: page, per_page: 50 })
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
