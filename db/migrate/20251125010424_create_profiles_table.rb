class CreateProfilesTable < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.text :bio
      t.boolean :email_notifications, default: true
      t.boolean :weekly_digest, default: true
      t.boolean :public_profile, default: false
      t.string :timezone, default: "UTC"
      t.string :language, default: "en"
      t.json :preferences
      t.timestamps
    end
  end
end
