class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.references :user
      t.text :full_text
      t.text :url

      t.timestamps
    end
  end
end
