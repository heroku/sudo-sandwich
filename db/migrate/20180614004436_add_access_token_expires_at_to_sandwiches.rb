class AddAccessTokenExpiresAtToSandwiches < ActiveRecord::Migration[5.1]
  def change
    add_column :sandwiches, :access_token_expires_at, :datetime
  end
end
