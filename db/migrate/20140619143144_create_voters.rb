class CreateVoters < ActiveRecord::Migration
  def change
    create_table :voters do |t|
      t.string :phone_number

      t.timestamps
    end
  end
end
