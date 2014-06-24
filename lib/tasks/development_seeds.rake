if Rails.env.development?
  require 'factory_girl'

  namespace :dev do
    desc 'Seed data for development environment'
    task prime: 'db:setup' do
      # FactoryGirl.find_definitions
      include FactoryGirl::Syntax::Methods

      dev_phone_numbers = ["617-555-1212", "2125551212", "(202) 555-1212"]


      create :yes_no_poll_with_uncast_votes, question: "Do you forgive me?", phone_numbers: dev_phone_numbers
      create :yes_no_poll_with_photo_and_uncast_votes, question: "Play Marco Polo?", phone_numbers: dev_phone_numbers
      create :yes_no_poll_with_photo_and_uncast_votes, question: nil, phone_numbers: dev_phone_numbers

      create_list(:yes_no_poll_with_uncast_votes, 50)
    end
  end
end
