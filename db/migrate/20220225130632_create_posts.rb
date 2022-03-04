class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :shopname
      t.string :img
      t.integer :assessment
      t.text :comment
      t.string :shopurl
      t.string :user_id
      t.timestamps null: false
    end
  end
end
