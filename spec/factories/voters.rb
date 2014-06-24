# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :voter do
    phone_number "617-555-0001"

    factory :boston_voter do
      phone_number "1 (617) 555-0002"
    end

    factory :nyc_voter do
      phone_number "2125550003"
    end

    factory :dc_voter do
      phone_number "202 555-0004"
    end
  end
end
