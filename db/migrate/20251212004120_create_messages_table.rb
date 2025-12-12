class CreateMessagesTable < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.text :content, null: false
      t.references :thread, null: false, foreign_key: {to_table: :threads}
      t.references :user, null: false, foreign_key: true
      t.integer :parent_message_id
      t.datetime :edited_at
      t.timestamps
    end

    add_index :messages, :parent_message_id
  end
end
