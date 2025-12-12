class CreateThreadsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :threads do |t|
      t.string :title, null: false
      t.text :description
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :pinned, default: false
      t.boolean :locked, default: false
      t.timestamps
    end
  end
end
