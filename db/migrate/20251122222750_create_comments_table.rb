class CreateCommentsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.string :attachment
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: {on_delete: :cascade}
      t.timestamps
    end
  end
end
