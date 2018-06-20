class AddStateToSandwiches < ActiveRecord::Migration[5.1]
  def change
    add_column :sandwiches, :state, :string
  end
end
