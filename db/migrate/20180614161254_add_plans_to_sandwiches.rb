class AddPlansToSandwiches < ActiveRecord::Migration[5.1]
  def change
    add_column :sandwiches, :plan, :string
  end
end
