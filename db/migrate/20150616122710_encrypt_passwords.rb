class User < ActiveRecord::Base; end

class EncryptPasswords < ActiveRecord::Migration
  def change
    User.find_each do |user|
      user.update password: Digest::SHA1.hexdigest(user.password)
    end
  end
end
