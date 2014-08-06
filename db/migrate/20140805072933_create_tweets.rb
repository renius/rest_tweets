class CreateTweets < ActiveRecord::Migration
  def up
    create_table :tweets, id: false do |t|
      t.references :user
      t.text :full_text
      t.text :url
      t.integer :id, limit: 8

      t.timestamps
    end
    execute "ALTER TABLE tweets ADD PRIMARY KEY (id);"
  end

  def down
    drop_table :tweets
  end
end
