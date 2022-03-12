class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :post_id
      t.text :comment_content
      t.timestamps null: false
    end
  end
end
