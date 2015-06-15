require "minitest/autorun"
require "rack/test"

ENV["TEST"] = "true"

require_relative "./server"


class ServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    MusicBoxApp
  end

  def setup
    User.delete_all
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

  def test_user_signed_in
      james = User.create! name: "James", password: "hunter2"
      sign_in james
      
    if current_user
      assert_equal last_response.status, 200 
      assert_equal vote.button
      assert_equal song["list"]

    else
      refute vote.button
      refute add.button
    end
  end
end
