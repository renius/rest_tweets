class AddStates < ActiveRecord::Migration
  def change
    add_column :users, :base_state, :string
    add_column :users, :process_state, :string
    add_column :users, :blocked_at, :datetime
  end
end
