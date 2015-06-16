class Song < ActiveRecord::Base
  belongs_to :suggester, class_name: "User"

  has_many :votes
  has_many :users, through: :votes

  validates_presence_of :title, :artist, :suggester
  validates_uniqueness_of :title, scope: :artist

  def total_votes 
    # votes.sum(:value)
    Vote.where(song_id: self.id).sum(:value)
  end
end