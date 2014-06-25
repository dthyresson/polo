class Poll < ActiveRecord::Base
  belongs_to :author
  has_many :choices
  has_many :votes
  has_many :voters, through: :votes

  validates_presence_of :author
  validates_presence_of :phone_numbers

  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                                         :default_url => "/images/:style/missing.png"
  process_in_background :photo

  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :photo, in: (0..2.megabytes)

  validate :has_question_or_photo?

  accepts_nested_attributes_for :author
  accepts_nested_attributes_for :choices

  before_save :normalize_phone_numbers!

  def photo_url(style)
    photo && photo.url(style)
  end

  def has_photo?
    photo.present?
  end

  def self.for_author(author)
    where("author_id = ?", author.id)
  end

  def self.ended
    where("closed_at is not null")
  end

  def end!
    update_attributes({ closed_at: Time.zone.now })
  end

  def open!
    update_attributes({ closed_at: nil })
  end

  def over?
    not in_progress?
  end

  def self.in_progress
    where("closed_at is null")
  end

  def in_progress?
    closed_at.nil?
  end

  def self.ordered
    order("updated_at desc")
  end

  def self.recent
    where("created_at >= ?", 2.weeks.ago)
  end

  def author_name
    author.name
  end

  def author_device_id
    author.device_id
  end

  def has_question?
    question.present?
  end

  def has_phone_numbers?
    phone_numbers.present?
  end

  def notified_voters
    votes.includes(:voter).notified.map(&:voter)
  end

  def notified_voters_count
    notified_voters.size
  end

  def notified_phone_numbers
    notified_voters.map(&:phone_number)
  end

  def notified_formatted_phone_numbers
    notified_voters.map(&:formatted_phone_number)
  end

  def vote_cast!
    calculate_popularity!
    end! if ok_to_auto_close?
  end

  def votes_cast_count
    votes.cast_count
  end

  def calculate_popularity!
    choices.each do |choice|
      choice.update_attribute(:popularity, choice.votes_cast_count / votes.cast.count.to_f)
    end
  end

  def votes_remaining_count
    votes.count - votes_cast_count
  end

  def ok_to_auto_close?
    votes_cast_count == votes.count
  end

  def publish_to_voters
    if phone_numbers.present?
      phone_numbers.each do |phone_number|
        begin
          voter = Voter.find_or_create_by({ phone_number: phone_number })
          vote = Vote.find_or_create_by({ voter: voter, poll: self })
          if PollNotifier.new(self).send_sms(vote)
            vote.notify!
          end
        end
      end
    end
  end

  def remind_uncast_voters!
    return if reminded?
    votes.uncast.each do |vote|
      if PollNotifier.new(self).send_sms(vote)
        vote.notify!
      end
    end
    remind!
  end

  def remind!
    update_attribute(:reminded_at, Time.zone.now)
  end

  def reminded?
    reminded_at.present?
  end

  def top_choice
    @top_choice ||= begin
                      top = choices.by_popularity.first
                      if not tied?
                        top
                      else
                        Choice.new({ title: "Tied", popularity: top.popularity })
                      end
                    end
  end

  def tied?
    if choices.count <= 1
      return false
    end

    top_choices = choices.by_popularity.take(2)
    top_choices.map(&:popularity).uniq.size == 1
  end

  private

  def has_question_or_photo?
    unless has_question? || has_photo?
      errors.add(:base, "Need to ask a question or show a photo")
    end
  end

  def normalize_phone_numbers!
    tel = []
    if self.has_phone_numbers?
      self.phone_numbers.each do |phone_number|
        normalized_phone_number = PhonyRails.normalize_number(phone_number, :country_code => 'US')
        if Phony.plausible?(normalized_phone_number)
          tel << normalized_phone_number
        end
      end
    end
    self.phone_numbers = tel
  end
end
