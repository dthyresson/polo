class Poll < ActiveRecord::Base
  belongs_to :author
  has_many :choices
  has_many :votes
  has_many :voters, through: :votes

  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                                       :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :photo, in: (0..2.megabytes)

  validates_presence_of :question

  accepts_nested_attributes_for :author
  accepts_nested_attributes_for :choices

  def photo_url(style)
    if photo.file?
      photo.url(style)
    else
      nil
    end
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

  def in_progress?
    closed_at.nil?
  end

  def over?
    not in_progress?
  end

  def votes_cast_count
    votes.cast_count
  end

  def publish_to_voter_phone_numbers(phone_numbers = nil)
    if phone_numbers
      phone_numbers.each do |phone_number|
        voter = Voter.find_or_create_by({phone_number: phone_number})
        Vote.create({voter: voter, poll: self})
      end
    end
  end

  def to_builder(phone_numbers = nil)
    Jbuilder.encode do |json|
      json.poll do
        json.author_name self.author_name
        json.author_device_id self.author_device_id
        json.question self.question
        json.choices_attributes self.choices do |choice|
          json.title choice.title
        end
        if phone_numbers.present?
          json.phone_numbers phone_numbers
        end
      end
    end
  end
end
