if Rails.env.development?
  require 'factory_girl'

  namespace :dev do
    desc 'Seed data for development environment'
    task prime: 'db:setup' do
      # FactoryGirl.find_definitions
      include FactoryGirl::Syntax::Methods

      dev_phone_numbers = ["16172304800", "16172304800", "16175551212"]

      create :yes_no_poll_with_uncast_votes, question: "Do you forgive me?", phone_numbers: dev_phone_numbers
      create :yes_no_poll_with_photo_and_uncast_votes, question: "Play Marco Polo?", phone_numbers: dev_phone_numbers
      create :yes_no_poll_with_photo_and_uncast_votes, question: nil, phone_numbers: dev_phone_numbers
    end
  end
end
