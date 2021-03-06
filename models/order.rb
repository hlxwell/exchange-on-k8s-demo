class Order < ActiveRecord::Base
  belongs_to :user
  has_many :buy_trades
  has_many :sell_trades

  scope :buy, -> { where(side: "buy") }
  scope :sell, -> { where(side: "sell") }
  scope :active, -> { where(status: "active") }
  scope :done, -> { where(status: "done") }

  validates :volume, numericality: {greater_than: 0}, on: :create
  validate :check_affordability_for_buy_order, on: :create, if: :buy_order?
  validate :check_affordability_for_sell_order, on: :create, if: :sell_order?

  before_create do
    self.left_volume = volume # init volume

    self.buy_currency = buy_currency()
    self.sell_currency = sell_currency()
  end

  before_update do
    self.status = "done" if self.left_volume <= 0
  end

  after_create do
    strike_and_create_trades
  end

  # for BUY order, make sure it has money.
  def check_affordability_for_buy_order
    total_price = self.price * self.volume
    user_balance = self.user.balance_in(sell_currency)
    if user_balance < total_price
      errors.add :volume, "is less than user balance. #{user_balance} < request: #{total_price}"
    end
  end

  # for SELL order, make sure it has enough coin.
  def check_affordability_for_sell_order
    user_balance = self.user.balance_in(buy_currency)
    if user_balance < self.volume
      errors.add :volume, "is less than user balance. #{user_balance} < request: #{self.volume}"
    end
  end

  # strike only for volume
  def strike!(order)
    deal_volume = if self.left_volume >= order.left_volume
                    order.left_volume
                  else
                    self.left_volume
                  end

    self.left_volume -= deal_volume
    order.left_volume -= deal_volume
    self.save!
    order.save!

    [self.price, deal_volume]
  end

  def strike_and_create_trades
    target_orders = []
    if self.buy_order?
      target_orders = self.class.active.sell
        .where("pair = ? AND price <= ? AND left_volume > 0", self.pair, self.price)
        .order(:created_at, :price)
    else
      target_orders = self.class.active.buy
        .where("pair = ? AND price >= ? AND left_volume > 0", self.pair, self.price)
        .order(:created_at, price: :desc)
    end

    transaction do
      target_orders.each do |order|
        # strike until current order is satisfied.
        break if self.left_volume <= 0

        deal_price, deal_volume = self.strike! order
        ask, bid = self.buy_order? ? [order, self] : [self, order]
        Trade.create!(
          pair: self.pair,
          price: deal_price,
          amount: deal_volume,
          bid_order: bid,
          ask_order: ask,
        )
      end
    end
  end

  def buy_currency
    self.pair.scan(/\w{3}/).first
  end

  def sell_currency
    self.pair.scan(/\w{3}/).last
  end

  def buy_order?
    side == "buy"
  end

  def sell_order?
    side == "sell"
  end
end
