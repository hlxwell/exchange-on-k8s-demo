class User < ActiveRecord::Base
  def self.login(email, password)
    u = find_by(email: email)
    if u.try(:password)
      BCrypt::Password.new(u.password) == password
    end
  end
end
