class Vote < ActiveRecord::Base
  belongs_to :voter, counter_cache: true
  belongs_to :poll, counter_cache: true, touch: true
  belongs_to :choice, counter_cache: true, touch: true

  def self.find_by_short_url(hashid)
    id = HASHIDS.decrypt(hashid)
    Vote.find(id).first
  end

  def short_url
    HASHIDS.encrypt(self.id)
  end

  def self.cast
    where("choice_id is not null")
  end

  def self.cast_count
    self.cast.count
  end

  def cast!(choice)
    return if poll.over?
    update_attributes({ choice: choice, cast_at: Time.zone.now })
    poll.calculate_popularity!
    poll.end! if poll.ok_to_auto_close?
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
    voter.phone_number if voter.present?
  end

  def votable?
    return false if poll.over?
    return false if cast?
    true
  end

  def self.notified
    where("notified_at is not null")
  end

  def notify!
    update_attribute(:notified_at, Time.zone.now)
  end

  def notified?
    notified_at.present?
  end

  def phone_number
    voter.phone_number if voter.present?
  end

  def formatted_phone_number
    voter.formatted_phone_number if voter.present?
  end

end
