class AddRemindedAtToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :reminded_at, :datetime
  end
end
