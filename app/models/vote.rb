class Vote < ActiveRecord::Base
  belongs_to :voter, counter_cache: true
  belongs_to :poll, counter_cache: true
  belongs_to :choice, counter_cache: true

  def self.find_by_short_url(hashid)
    id = HASHIDS.decrypt(hashid)
    Vote.find(id).first
  end

  def self.cast
    where("choice_id is not null")
  end

  def self.cast_count
    self.cast.count
  end

  def short_url
    HASHIDS.encrypt(self.id)
  end

  def cast!(choice)
    update_attributes({ choice: choice, cast_at: Time.zone.now })
  end

  def cast?
    choice.present?
  end

  def choice_title
    choice.title if choice.present?
  end

  def question
    poll.question
  end

  def voter_phone_number
    voter.phone_number
  end

  def votable?
    return false if poll.over?
    return false if cast?
    true
  end
end
