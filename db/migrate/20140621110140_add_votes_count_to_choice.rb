class AddVotesCountToChoice < ActiveRecord::Migration
  def change
    add_column :choices, :votes_count, :integer, default: 0
  end
end
