require "minitest/autorun"
require "rack/test"

require 'pry'

ENV["TEST"] = "true"

require './db/setup'
require './lib/all'
require './server'


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

  def sign_in user, password
    # This is a helper method that you can call to sign a particular user in
    post "/take_sign_in", username: user.name, password: password
  end

  def test_users_can_log_in
    katie = User.create! name: "Katie", password: "hunter2"

    sign_in katie, "hunter2"
    assert last_response.redirect?

    response = get "/"
    assert_equal response.status, 200
    assert_includes response.body, katie.name
  end

  def test_users_can_fail_to_log_in
    User.create! name: "user", password: "password"

    response = post "/take_sign_in", username: "Katie", password: "password"
    assert response.redirect?
    assert_includes response.location, "/sign_in"
  end

  # # def test_users_can_log_out
  # #   response = post "/sign_out", username: "Katie", password: "password"
  # #   assert_includes response.body, "You have been logged out"
  # # end

  def test_users_can_upvote_and_downvote
    katie = User.create! name: "Katie", password: "hunter2", votes_left: 10
    test_song = Song.create! suggester_id: katie.id, artist: "The Polly's", title: "Fake Song"

    sign_in katie, "hunter2"

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

    sign_in katie, "hunter2"

    post "/vote", song_title: test_song.title, value: 1

    assert_equal 400, last_response.status
    assert_includes last_response.body, "You have exceeded your weekly vote limit!"
  end

  def test_user_signed_in
    james = User.create! name: "James", password: "hunter2"
    sign_in james, "hunter2"
    song = james.suggested_songs.create! artist: "ODESZA", title: "All We Need"
    response = get "/"
    assert_includes response.body, "vote"
    assert_equal last_response.status, 200 
    assert_includes response.body, "suggest"
    assert_includes response.body, "artist: ODESZA, title: All We Need"
  end

  def test_user_not_signed_in
    james = User.create! name: "James", password: "hunter2"

    song = james.suggested_songs.create! artist: "ODESZA", title: "All We Need"
    response = get "/"
    refute_includes response.body, "vote"
    refute_includes response.body, "suggest"
    assert_includes response.body, song.artist
    assert_includes response.body, song.title
  end

  def test_admin_can_remove_user
    katie = User.create! name: "Katie", password: "hunter2", admin: true
    james = User.create! name: "James", password: "hunter3"

    sign_in katie, "hunter2"

    patch "/delete_user", name: james.name

    assert_equal true, katie.admin?
    assert_equal 200, last_response.status
    assert_equal nil, User.find_by_name(james.name)
    assert_includes last_response.body, "James has been deleted."
  end

  def test_non_admin_cannot_remove_user
    katie = User.create! name: "Katie", password: "hunter2"
    james = User.create! name: "James", password: "hunter3"

    sign_in katie, "hunter2"

    patch "/delete_user", name: james.name

    assert_equal 200, last_response.status
    assert_equal james, james
    assert_includes last_response.body, "Insufficient privileges."
  end

  def test_admin_can_invite_users
    katie = User.create! name: "Katie", password: "hunter2", admin: true

    sign_in katie, "hunter2"

    post "/invite_user", name: "Bella", password: "password"

    assert_equal 200, last_response.status
    assert_equal 2, User.count
    assert_equal "Bella", User.last.name
  end

  def test_non_admin_cannot_invite_users
    katie = User.create! name: "Katie", password: "hunter2"

    sign_in katie, "hunter2"

    post "/invite_user", name: "Bella"

    assert_equal 200, last_response.status
    assert_equal 1, User.count
    assert_includes last_response.body, "Insufficient privileges."
  end

  def test_admin_can_grant_admin_status
    katie = User.create! name: "Katie", password: "hunter2", admin: true
    james = User.create! name: "James", password: "hunter3"

    sign_in katie, "hunter2"

    patch "/assign_admin", name: james.name
    # binding.pry
    assert_equal 200, last_response.status
    assert_equal true, User.find_by_name(james.name).admin?
  end

  def test_admin_can_revoke_admin_status
    katie = User.create! name: "Katie", password: "hunter2", admin: true
    james = User.create! name: "James", password: "hunter3", admin: true

    sign_in katie, "hunter2"

    patch "/assign_admin", name: james.name
    binding.pry
    assert_equal 200, last_response.status
    assert_equal true, User.find_by_name(james.name).admin?
  end

  def test_non_admin_cannot_grant_admin_status
    katie = User.create! name: "Katie", password: "hunter2"
    james = User.create! name: "James", password: "hunter3"

    sign_in katie, "hunter2"

    patch "/assign_admin", name: james.name

    assert_equal 200, last_response.status
    assert_equal false, User.find_by_name(james.name).admin?
  end
end