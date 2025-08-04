class CreatePurchases < ActiveRecord::Migration[8.0]
  def up
    create_table :purchases do |t|
      t.string  :ref_trade_id, null: false
      t.string  :ref_user_id, null: false
      t.string  :od_currency, null: false
      t.decimal :od_price, null: false, precision: 10, scale: 2
      t.string  :return_url, null: false
      t.string  :access_token
      t.string  :od_id
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :purchases, :ref_trade_id, unique: true
  end

  def down
    drop_table :purchases
  end
end
