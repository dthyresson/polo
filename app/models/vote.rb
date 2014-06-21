class Vote < ActiveRecord::Base
  belongs_to :voter
  belongs_to :poll
  belongs_to :choice

  def short_url
    HASHIDS.encrypt(self.id)
  end

  def cast!(choice)
    update_attributes({choice: choice})
  end

  def cast?
    choice.present?
  end

  def choice_title
    choice.title if choice.present?
  end

  def voter_phone_number
    voter.phone_number
  end
end
