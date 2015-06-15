class User < ActiveRecord::Base
  has_many :votes

  # These would be ambiguous
  # has_many :songs
  # has_many :songs, through: :votes
  # FIXME
  has_many :suggested_songs, class_name: "Song"
  has_many :voted_songs, through: :votes

  validates_presence_of :name, :password
  validates_uniqueness_of :name
  # TODO: validates length of password?
end
