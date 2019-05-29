class AccountEntry < ActiveRecord::Base
  belongs_to :entryable, polymorphic: true
end
