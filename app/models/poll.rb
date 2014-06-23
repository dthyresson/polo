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

  def photo_url(style)
    if photo.file?
      photo.url(style)
    else
      nil
    end
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

  def self.in_progress
    where("closed_at is null")
  end

  def author_name
    author.name
  end

  def author_device_id
    author.device_id
  end

  def end!
    update_attributes({ closed_at: Time.zone.now })
  end

  def has_question?
    question.present?
  end

  def in_progress?
    closed_at.nil?
  end

  def over?
    not in_progress?
  end

  def votes_cast_count
    votes.cast_count
  end

  def calculate_popularity!
    choices.each do |choice|
      choice.update_attribute(:popularity, choice.votes.cast.count / votes.cast.count.to_f)
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
        voter = Voter.find_or_create_by({phone_number: phone_number})
        Vote.create({voter: voter, poll: self})
        unless Rails.env.test?
          begin
            TWILIO.account.messages.create(
              from: TWILIO_PHONE_NUMBER,
              to: phone_number,
              body: "#{author_name} wants to know, \"#{question}\""
            )
          rescue Twilio::REST::RequestError => e
            # send this to airbrake?
            # delete the vote and remove the phone number?
            puts e.message
          end
        end
      end
    end
  end

  def top_choice
    @top_choice ||= begin
                      top = choices.by_popularity.first
                      if not tied?
                        top
                      else
                        Choice.new({title: "Tied", popularity: top.popularity})
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
    unless has_question? or has_photo?
      errors.add(:base, "Need to ask a question or show a photo")
    end
  end
end
