require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :votes, foreign_key: "voter_id"

  # These would be ambiguous
  # has_many :songs
  # has_many :songs, through: :votes
  # FIXME
  has_many :suggested_songs, class_name: "Song", foreign_key: "suggester_id"
  has_many :voted_songs, through: :votes, source: :song

  validates_presence_of :name, :password
  validates_uniqueness_of :name
  # TODO: validates length of password?

  def self.encrypt_password password
    # Note: this isn't the best choice of hash function
    Digest::SHA1.hexdigest password
  end

  def password= unencrypted_password
    super User.encrypt_password(unencrypted_password)
  end

  def num_of_songs_suggested_this_week
    suggested_songs.where('created_at >= ?', 1.week.ago).count
  end

end
