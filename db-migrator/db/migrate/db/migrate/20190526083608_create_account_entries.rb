class CreateAccountEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :account_entries do |t|
      t.string :entryable_type, null: false
      t.integer :entryable_id, null: false
      t.decimal :credit_amount
      t.integer :credit_account_id
      t.decimal :debit_amount
      t.integer :debit_account_id
      t.string :currency, null: false
      t.timestamps
    end
  end
end
