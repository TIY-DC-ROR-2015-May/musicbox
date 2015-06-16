class PlaylistSong < ActiveRecord::Base
  belongs_to :song
  belongs_to :playlist

  validates_presence_of :song, :playlist
  validates_uniqueness_of :song, scope: :playlist
end