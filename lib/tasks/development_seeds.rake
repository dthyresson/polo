if Rails.env.development?
  require 'factory_girl'

  namespace :dev do
    desc 'Seed data for development environment'
    task prime: 'db:setup' do
      # FactoryGirl.find_definitions
      include FactoryGirl::Syntax::Methods

      create :yes_no_poll_with_uncast_votes, question: "Do you forgive me?"
      create :yes_no_poll_with_photo_and_uncast_votes, question: "Play Marco Polo?"
      create :yes_no_poll_with_photo_and_uncast_votes, question: nil
    end
  end
end
