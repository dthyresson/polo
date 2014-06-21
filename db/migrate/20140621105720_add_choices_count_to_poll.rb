class AddChoicesCountToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :choices_count, :integer, default: 0
  end
end
