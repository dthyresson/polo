class Voter < ActiveRecord::Base
  phony_normalize :phone_number, :default_country_code => 'US'    
  validates_plausible_phone :phone_number, :presence => true
end
