class CreateProjectsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      # Optional cover image URL
      t.string :cover_url
      # Whether the project is active
      t.boolean :active, default: false, null: false
      # Tags stored as JSON text (use model accessor for Array)
      t.text :tags, default: "[]"
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :projects, :active
  end
end
