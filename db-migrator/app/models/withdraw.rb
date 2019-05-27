class Withdraw < ActiveRecord::Base
  belongs_to :user
  has_many :account_entries, as: :entryable

  after_create do
    AccountEntry.create!(
      entryable: self,
      debit_amount: self.amount,
      debit_account_id: self.user_id,
      currency: self.currency,
    )
  end
end
