class CreateSandwiches < ActiveRecord::Migration[5.1]
  def change
    create_table :sandwiches do |t|
      t.timestamps null: false
      t.string :heroku_uuid, null: false
      t.string :encrypted_oauth_grant_code
      t.string :encrypted_oauth_grant_code_iv
    end
  end
end
