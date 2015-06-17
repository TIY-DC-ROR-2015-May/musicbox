class DefaultVotesLeft < ActiveRecord::Migration
  def change
    change_column :users, :votes_left, :integer, default: 10
  end
end