# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :choice do
    poll
    title "Yes"
    popularity 50

    factory :yes_choice do
      title "Yes"
      popularity 60
    end

    factory :no_choice do
      title "No"
      popularity 40
    end
  end
end
