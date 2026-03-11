class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :reference, null: false
      t.string :status, null: false, default: "pending"
      t.string :customer_name, null: false
      t.string :customer_email, null: false
      t.string :tracking_number
      t.string :carrier
      t.text :notes
      t.integer :total_cents, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :orders, :reference, unique: true
    add_index :orders, :status
    add_index :orders, :customer_email
  end
end
