class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.references :author, index: true
      t.text :question

      t.timestamps
    end
  end
end
