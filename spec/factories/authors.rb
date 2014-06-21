# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :author do
    name "Marco Polo"
    phone_number "617-555-1212"

    factory :author_with_device do
      after(:create) do |author, evaluator|
        create(:device, author: author, device_id: SecureRandom.hex(10))
      end
    end
  end
end
