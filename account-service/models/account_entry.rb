class AccountEntry < ActiveRecord::Base
  belongs_to :credit_account, class_name: "User"
  belongs_to :debit_account, class_name: "User"
end
