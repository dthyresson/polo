class Choice < ActiveRecord::Base
  belongs_to :poll
  has_many :votes
  has_many :voters, through: :votes
  has_many :authors, through: :poll

  validates_presence_of :title
  validates_numericality_of :popularity, greater_than_or_equal_to: 0

  accepts_nested_attributes_for :votes
end
