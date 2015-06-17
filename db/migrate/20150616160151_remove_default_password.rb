class RemoveDefaultPassword < ActiveRecord::Migration
  def change
    change_column :users, :password, :string
  end
end
