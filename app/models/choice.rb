class Choice < ActiveRecord::Base
  belongs_to :poll, counter_cache: true
  has_many :votes
  has_many :voters, through: :votes
  has_many :authors, through: :poll

  validates_presence_of :title
  validates_numericality_of :popularity, greater_than_or_equal_to: 0

  accepts_nested_attributes_for :votes

  def self.ordered
    order("title desc")
  end

  def self.by_popularity
    order("popularity desc")
  end

  def votes_cast
    votes.cast.first || NullVote.new
  end

  def votes_cast_count
    votes.cast.count
  end
end
