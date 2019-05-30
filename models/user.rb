require "bcrypt"
require "digest/sha1"

class User < ActiveRecord::Base
  has_many :deposites
  has_many :withdraws
  has_many :orders
  has_many :sell_orders, -> { where(side: "sell") }, class_name: "Order"
  has_many :buy_orders, -> { where(side: "buy") }, class_name: "Order"

  has_many :credit_account_entries, foreign_key: :credit_account_id, class_name: "AccountEntry"
  has_many :debit_account_entries, foreign_key: :debit_account_id, class_name: "AccountEntry"

  has_many :buy_trades, foreign_key: :buyer_id, class_name: "Trade"
  has_many :sell_trades, foreign_key: :seller_id, class_name: "Trade"

  validates :email, uniqueness: true

  def self.register(email, password)
    create(email: email, password: BCrypt::Password.create(password))
  end

  def balance_in(currency)
    credit = credit_account_entries.where(currency: currency).sum :credit_amount
    debit = debit_account_entries.where(currency: currency).sum :debit_amount
    credit - debit
  end

  def self.login(email, password)
    u = User.find_by(email: email)
    token = nil
    if BCrypt::Password.new(u.password) == password
      token = Digest::SHA1.hexdigest(Time.now.to_s)
      u.update_attributes! token: token
    end
    token
  end
end
