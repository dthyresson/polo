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

    factory :choice_with_votes do
      after(:create) do |choice, evaluator|
        create(:vote, poll: choice.poll)
      end
    end

    factory :choice_with_cast_votes do
      after(:create) do |choice, evaluator|
        create(:vote, poll: choice.poll, choice: choice)
      end
    end
  end
end
