require 'spec_helper'

describe Choice, "associations" do
  it { should belong_to :poll }
  it { should have_many :votes }
  it { should have_many(:voters).through(:votes) }
  it { should have_many(:authors).through(:poll) }
  it { should accept_nested_attributes_for :votes }
end

describe Choice, "validations" do
  it { should validate_presence_of :title}
  it { should validate_numericality_of(:popularity).is_greater_than_or_equal_to(0) }
end
