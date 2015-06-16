class AddPasswordDefault < ActiveRecord::Migration
  def change
    change_column :users, :password, :string, default: SecureRandom.hex(12)
    end
end
