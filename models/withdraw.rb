# frozen_string_literal: true

class Withdraw < ActiveRecord::Base
  belongs_to :user
  has_many :account_entries, as: :entryable

  validate :check_balance, on: :create
  # TODO: Validate amount and currency

  after_create do
    AccountEntry.create!(
      entryable: self,
      debit_amount: amount,
      debit_account_id: user_id,
      currency: currency
    )
  end

  def check_balance
    balance = user.balance_in(currency)
    return if balance > amount

    errors.add :amount,
               "is greater than user available balance. balance: #{balance} < request: #{amount}"
  end
end
