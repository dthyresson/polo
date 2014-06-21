class AddDevicesCountToAuthor < ActiveRecord::Migration
  def change
    add_column :authors, :devices_count, :integer, default: 0
  end
end
