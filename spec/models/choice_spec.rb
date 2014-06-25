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

describe Choice, ".ordered" do
  it "orders the choices for display inverse alphabeticaly so Yes comes before No" do
    alice_choice = create :choice, title: "Alice"
    doug_choice = create :choice, title: "Doug"
    bob_choice = create :choice, title: "Bob"
    fred_choice = create :choice, title: "Fred"
    charlie_choice = create :choice, title: "Charlie"

    expect(Choice.ordered).to eq([fred_choice, doug_choice, charlie_choice, bob_choice, alice_choice])
  end
end

describe Choice, ".by_popularity" do
  it "orders the choices for display inverse alphabeticaly so Yes comes before No" do
    alice_choice = create :choice, title: "Alice", popularity: 0
    doug_choice = create :choice, title: "Doug", popularity: 0.30
    bob_choice = create :choice, title: "Bob", popularity: 0.12
    fred_choice = create :choice, title: "Fred", popularity: 0.40
    charlie_choice = create :choice, title: "Charlie", popularity: 0.18

    expect(Choice.by_popularity).to eq([fred_choice, doug_choice, charlie_choice, bob_choice, alice_choice])
  end
end

describe Choice, "#votes_cast" do
  it "returns votes cast for the choice" do
    choice = create :choice
    vote = create :vote, poll: choice.poll, choice: choice

    expect(choice.votes_cast).to eq(choice.votes.first)
  end
end


describe Choice, "#votes_cast_count" do
  it "counts the number of votes cast for the choice" do
    choice = create :choice_with_cast_votes

    expect(choice.votes_cast_count).to eq(1)
  end
end
