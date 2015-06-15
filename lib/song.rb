class Song < ActiveRecord::Base
  belongs_to :suggester, class_name: "User"

  has_many :votes
  has_many :users, through: :votes

  validates_presence_of :title, :artist, :suggester
  validates_uniqueness_of :title, scope: :artist

  def total_votes 
    total_votes = 0
    all_votes = Vote.where(song_id: self.id ).sum(:value)
    total_votes += all_votes
    # binding.pry
  end
end