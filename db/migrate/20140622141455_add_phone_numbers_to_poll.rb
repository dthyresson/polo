class AddPhoneNumbersToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :phone_numbers, :string, array: true, default: '{}'
  end
end
