class Deposite < ActiveRecord::Base
  belongs_to :user
  has_many :account_entries, as: :entryable

  after_create do
    AccountEntry.create!(
      entryable: self,
      credit_amount: self.amount,
      credit_account_id: self.user_id,
      currency: self.currency,
    )
  end
end
