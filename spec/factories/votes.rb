# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vote do
    voter
    choice
    notified_at nil

    factory :notified_vote do
      notified_at { Time.zone.now }
    end
  end
end
