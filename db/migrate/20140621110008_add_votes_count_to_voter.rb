class AddVotesCountToVoter < ActiveRecord::Migration
  def change
    add_column :voters, :votes_count, :integer, default: 0
  end
end
