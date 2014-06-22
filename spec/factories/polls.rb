# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :poll, aliases: [:open_poll] do
    author
    question "Should I travel through Asia?"
    photo nil
    closed_at nil

    factory :closed_poll do
      closed_at { Time.zone.now }
    end

    factory :yes_no_poll do
      author factory: :author_with_device
      after(:create) do |poll, evaluator|
        create(:yes_choice, poll: poll, popularity: 0)
        create(:no_choice, poll: poll, popularity: 0)
      end

      factory :yes_no_poll_with_phone_numbers do
        phone_numbers ["16175551212", "12125551212", "12025551212"]
      end

      factory :yes_no_poll_with_photo do
        before(:create) do |poll, evaluator|
          poll.photo = File.new(File.expand_path("spec/fixtures/marco-polo-600x450.jpg"))
        end

        factory :yes_no_poll_with_photo_and_uncast_votes do
          after(:create) do |poll, evaluator|
            boston_voter = create :boston_voter
            create(:vote, poll: poll, voter: boston_voter, choice: nil)

            nyc_voter = create :nyc_voter
            create(:vote, poll: poll, voter: nyc_voter, choice: nil)

            dc_voter = create :dc_voter
            create(:vote, poll: poll, voter: dc_voter, choice: nil)
          end
        end
      end

      factory :yes_no_poll_with_uncast_votes do
        after(:create) do |poll, evaluator|
          boston_voter = create :boston_voter
          create(:vote, poll: poll, voter: boston_voter, choice: nil)

          nyc_voter = create :nyc_voter
          create(:vote, poll: poll, voter: nyc_voter, choice: nil)

          dc_voter = create :dc_voter
          create(:vote, poll: poll, voter: dc_voter, choice: nil)
        end
      end
    end
  end
end
