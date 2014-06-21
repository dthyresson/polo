class Device < ActiveRecord::Base
  belongs_to :author, counter_cache: true

  validates_presence_of :device_id
end
