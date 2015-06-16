require "minitest/autorun"
require "rack/test"
require './db/setup'
require './lib/all'
require './server'

ENV["TEST"] = "true"

require_relative "./server"


class ServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    MusicBoxApp
  end

  def setup
    User.delete_all
    Song.delete_all
  end

  def sign_in user
    # This is a helper method that you can call to sign a particular user in
    post "/take_sign_in", username: user.name, password: user.password
  end

  def test_users_can_log_in
    katie = User.create! name: "Katie", password: "hunter2"

    sign_in katie
    assert last_response.redirect?

    response = get "/"
    assert_equal response.status, 200
    assert_includes response.body, katie.name
  end

  def test_users_can_fail_to_log_in
    User.create! name: "user", password: "password"

    response = post "/take_sign_in", username: "Katie", password: "password"
    refute response.redirect?
    assert_includes response.body, "Bad username or password"
  end

  def test_users_can_upvote_and_downvote
    katie = User.create! name: "Katie", password: "hunter2", votes_left: 10
    test_song = Song.create! suggester_id: katie.id, artist: "The Polly's", title: "Fake Song"

    sign_in katie

    5.times do
      post "/vote", song_title: test_song.title, value: 1
    end

    assert_equal 200, last_response.status
    assert_equal 5, test_song.total_votes

    3.times do
      post "/vote", song_title: test_song.title, value: -1
    end
    
    assert_equal 200, last_response.status
    assert_equal 2, test_song.total_votes
  end

  def test_users_have_limited_number_of_votes
    katie = User.create! name: "Katie", password: "hunter2", votes_left: 0
    test_song = Song.create! suggester_id: katie.id, artist: "The Polly's", title: "Fake Song"

    sign_in katie

    post "/vote", song_title: test_song.title, value: 1

    assert_equal 400, last_response.status
    assert_includes last_response.body, "You have exceeded your weekly vote limit!"
  end

end