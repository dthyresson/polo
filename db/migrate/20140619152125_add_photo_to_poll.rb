class AddPhotoToPoll < ActiveRecord::Migration
  def change
    add_attachment :polls, :photo
  end
end
