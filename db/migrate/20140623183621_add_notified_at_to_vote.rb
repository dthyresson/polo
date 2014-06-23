class AddNotifiedAtToVote < ActiveRecord::Migration
  def change
    add_column :votes, :notified_at, :datetime
  end
end
