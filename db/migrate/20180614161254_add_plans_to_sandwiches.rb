class AddPlansToSandwiches < ActiveRecord::Migration[5.1]
  def change
    add_column :sandwiches, :plan, :integer
  end
end
