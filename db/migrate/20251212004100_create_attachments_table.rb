class CreateAttachmentsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :attachments do |t|
      t.string :filename, null: false
      t.string :file_path, null: false
      t.string :content_type
      t.integer :file_size
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.timestamps
    end
  end
end
