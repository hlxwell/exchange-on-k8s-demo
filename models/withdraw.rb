class Withdraw < ActiveRecord::Base
  belongs_to :user
  has_many :account_entries, as: :entryable

  validate :check_balance, on: :create
  # TODO: Validate amount and currency

  after_create do
    AccountEntry.create!(
      entryable: self,
      debit_amount: self.amount,
      debit_account_id: self.user_id,
      currency: self.currency,
    )
  end

  def check_balance
    balance = self.user.balance_in(self.currency)
    if balance < self.amount
      errors.add :amount, "is greater than user available balance. balance: #{balance} < request: #{self.amount}"
    end
  end
end
