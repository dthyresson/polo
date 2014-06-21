class Author < ActiveRecord::Base
	has_many :devices

  validates_presence_of :name
	validates_plausible_phone :phone_number

	phony_normalize :phone_number, :default_country_code => 'US'

  def device_id
    device = devices.first
    device.device_id if device
  end
end
