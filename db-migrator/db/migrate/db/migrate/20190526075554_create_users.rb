class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, limit: 50, null: false
      t.string :password, null: false
      t.string :token
      t.index :token
      t.timestamps
    end
  end
end
