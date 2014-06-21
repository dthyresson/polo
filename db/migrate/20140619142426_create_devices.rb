class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :author, index: true
      t.string :device_id

      t.timestamps
    end
  end
end
