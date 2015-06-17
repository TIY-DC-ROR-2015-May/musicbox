class CreateDataModel < ActiveRecord::Migration
  def change
    create_table "users" do |t|
      t.string   "name"
      t.string   "password"
      t.integer  "votes_left"
      t.integer  "vetoes_left"
      t.boolean  "admin", default: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "songs" do |t|
      t.integer  "suggester_id"
      t.string   "artist"
      t.string   "title"
      t.string   "album"
      t.datetime "created_at"
    end

    create_table "votes" do |t|
      t.integer  "voter_id"
      t.integer  "song_id"
      t.integer  "value"
      t.datetime "created_at"
    end

    create_table "playlist_songs" do |t|
      t.integer "song_id"
      t.integer "playlist_id"
    end

    create_table "playlists" do |t|
      t.datetime "created_at"
    end
  end
end