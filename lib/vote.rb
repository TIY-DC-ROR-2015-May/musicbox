class Vote < ActiveRecord::Base
  belongs_to :voter, class_name: "User"
  belongs_to :song

  validates_presence_of :voter, :song, :value
  validates_inclusion_of :value, in: [-1, 1]
end
