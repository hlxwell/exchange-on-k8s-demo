class CreateDeposites < ActiveRecord::Migration[5.2]
  def change
    create_table :deposites do |t|
      t.integer :user_id, null: false
      t.index :user_id
      t.string :currency, null: false
      t.index :currency
      t.decimal :amount, default: 0
      t.integer :confirmations, default: 0
      t.string :status, default: "done" # pending, done
      t.timestamps
    end
  end
end
