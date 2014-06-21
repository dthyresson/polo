class AddCastAtToVote < ActiveRecord::Migration
  def change
    add_column :votes, :cast_at, :datetime
  end
end
