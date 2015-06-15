class Song < ActiveRecord::Base
  belongs_to :suggester, class_name: "User"

  has_many :votes
  has_many :users, through: :votes

  validates_presence_of :title, :artist, :suggester
  validates_uniqueness_of :title, scope: :artist
end
