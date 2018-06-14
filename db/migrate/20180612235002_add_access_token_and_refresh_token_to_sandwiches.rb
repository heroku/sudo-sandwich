class AddAccessTokenAndRefreshTokenToSandwiches < ActiveRecord::Migration[5.1]
  def change
    change_table :sandwiches do |t|
      t.string :encrypted_access_token
      t.string :encrypted_access_token_iv
      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv
    end
  end
end
