class Voter < ActiveRecord::Base
  phony_normalize :phone_number, :default_country_code => 'US'
  validates_plausible_phone :phone_number, :presence => true

  def formatted_phone_number
    return "" unless phone_number.present?
    phone_number.phony_formatted(:format => :international, :spaces => '-')
  end
end
