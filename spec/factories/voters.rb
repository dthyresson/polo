# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :voter do
    phone_number "16175550001"

    factory :boston_voter do
      phone_number "16175550002"
    end

    factory :nyc_voter do
      phone_number "12125550003"
    end

    factory :dc_voter do
      phone_number "12025550004"
    end
  end
end
