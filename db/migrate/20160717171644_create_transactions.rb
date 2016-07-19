class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :res_num
      t.datetime :res_date
      t.decimal :amount, :precision => 8, :scale => 2
      t.string :client_name
      t.integer :status, default: 0
      t.boolean :complete
      t.string :bt_customer
      t.string :bt_payment_method
      t.timestamps null: false
    end
  end
end
