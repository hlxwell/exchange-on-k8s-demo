class CreateTrades < ActiveRecord::Migration[5.2]
  def change
    create_table :trades do |t|
      t.integer :buyer_id, null: false
      t.index :buyer_id
      t.integer :seller_id, null: false
      t.index :seller_id
      t.decimal :price, null: false
      t.decimal :amount, null: false
      t.decimal :total_price, null: false
      t.integer :ask_order_id, null: false
      t.index :ask_order_id
      t.integer :bid_order_id, null: false
      t.index :bid_order_id
      t.string :pair, null: false
      t.index :pair
      t.timestamps
    end
  end
end
