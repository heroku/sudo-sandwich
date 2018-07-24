class CreateUsages < ActiveRecord::Migration[5.1]
  def change
    create_table :usages do |t|
      t.timestamps
      t.references :sandwich, null: false, index: true
      t.datetime :timestamp, null: false
      t.string :unit, null: false
      t.integer :quantity, null: false
      t.boolean :reported, default: false
      t.json :error_messages
    end
  end
end
