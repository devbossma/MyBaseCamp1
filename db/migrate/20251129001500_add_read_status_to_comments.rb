class AddReadStatusToComments < ActiveRecord::Migration[6.1]
  def change
    # Add boolean column to track if comment has been read by project owner
    add_column :comments, :read, :boolean, default: false, null: false

    # Add index for efficiently querying unread comments per project
    add_index :comments, [:project_id, :read], name: "index_comments_on_project_and_read"
  end
end
