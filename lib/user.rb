class User < ActiveRecord::Base
  has_many :votes

  # These would be ambiguous
  # has_many :songs
  # has_many :songs, through: :votes
  # FIXME
  has_many :suggested_songs, class_name: "Song", foreign_key: "suggester_id"
  has_many :voted_songs, through: :votes

  validates_presence_of :name, :password
  validates_uniqueness_of :name
  # TODO: validates length of password?

    def num_of_songs_suggested_this_week
      suggested_songs.where('created_at >= ?', 1.week.ago).count
    end

end