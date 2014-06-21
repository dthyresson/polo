class Device < ActiveRecord::Base
  belongs_to :author

  validates_presence_of :device_id
end
