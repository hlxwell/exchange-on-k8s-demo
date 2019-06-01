class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :side, null: false
      t.string :pair, null: false
      t.string :buy_currency
      t.string :sell_currency
      t.decimal :price, null: false
      t.decimal :volume, default: 0
      t.decimal :left_volume, default: 0
      t.string :status, default: "active" # active, done
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
