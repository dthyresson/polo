if Rails.env.development?
  require 'factory_girl'

  namespace :dev do
    desc 'Seed data for development environment'
    task prime: 'db:setup' do
      # FactoryGirl.find_definitions
      include FactoryGirl::Syntax::Methods

        create :yes_no_poll_with_uncast_votes, question: "Do you forgive me?"
    end
  end
end
