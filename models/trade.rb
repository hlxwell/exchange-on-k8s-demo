class Trade < ActiveRecord::Base
  has_many :account_entry, as: :entryable

  belongs_to :ask_order, class_name: "Order"
  belongs_to :bid_order, class_name: "Order"

  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  validates :price, :amount, :total_price, numericality: {greater_than: 0}

  before_validation do
    self.buyer = bid_order.user
    self.seller = ask_order.user
    self.total_price = price * amount
  end

  after_create do
    AccountEntry.create!(
      entryable: self,
      credit_amount: self.total_price,
      credit_account_id: self.seller_id,
      debit_amount: self.total_price,
      debit_account_id: self.buyer_id,
      currency: self.sell_currency,
    )

    AccountEntry.create!(
      entryable: self,
      credit_amount: self.amount,
      credit_account_id: self.buyer_id,
      debit_amount: self.amount,
      debit_account_id: self.seller_id,
      currency: self.buy_currency,
    )
  end

  def buy_currency
    self.pair.scan(/\w{3}/).first
  end

  def sell_currency
    self.pair.scan(/\w{3}/).last
  end
end
