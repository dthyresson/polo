require 'spec_helper'

describe Vote, "associations" do
  it { should belong_to :voter }
  it { should belong_to :poll }
  it { should belong_to :choice }
end

describe Vote, "validations" do
end

describe Vote, "#short_url" do
  it "should create a short url from the object's primary id" do
    vote = create :vote
    expect(vote.short_url).to_not be_empty
  end

  it "should be a certain length" do
    vote = create :vote
    expect(vote.short_url.length).to eq(6)
  end

  it "should be numbers and letters" do
    vote = create :vote
    expect(vote.short_url).to match(/[a-zA-Z0-9]/)
  end
end

describe Vote, "#cast!" do
  it "casts a vote for a choice" do
    poll = create :yes_no_poll_with_uncast_votes

    yes_choice = poll.choices.first
    no_choice = poll.choices.last
    vote = poll.votes.first

    vote.cast!(yes_choice)

    expect(vote).to be_cast
    expect(vote.cast_at).to be_present
    expect(vote.choice).to eq(yes_choice)
  end
end

describe Vote, "#cast?" do
  it "checks is a vote has been for a choice" do
    poll = create :yes_no_poll_with_uncast_votes
    vote = poll.votes.first
    vote.cast!(poll.choices.first)

    expect(vote.cast_at).to be_present
    expect(vote).to be_cast
  end
end

describe Vote, "#voter_phone_number" do
  it "reveals the voter's phone number" do
    poll = create :yes_no_poll_with_uncast_votes
    vote = poll.votes.first
    voter_phone_number = vote.voter.phone_number

    expect(vote.voter_phone_number).to be
    expect(vote.voter_phone_number).to eq(voter_phone_number)
  end
end

describe Vote, "#choice_title" do
  it "reveals the choice's title" do
    poll = create :poll
    choice_title = "My Choice"
    choice = create :choice, title: choice_title, poll: poll
    vote = create :vote, poll: poll, choice: choice

    expect(vote.choice_title).to eq(choice_title)
  end
end

describe Vote, "#find_by_short_url" do
  it "finds the vote based on the short url token" do
    vote = create :vote
    found_vote = Vote.find_by_short_url(vote.short_url)
    expect(found_vote).to be
    expect(found_vote.id).to eq(found_vote.id)
  end
end

describe Vote, "#question" do
  it "gets the question from the vote's poll" do
    question = "Do you like ice cream?"
    poll = create :poll, question: question
    vote = create :vote, poll: poll
    expect(vote.question).to eq(question)
  end
end

describe Vote, ".cast" do
  it "returns only cast votes" do
    poll = create :yes_no_poll_with_uncast_votes
    another_poll = create :yes_no_poll_with_uncast_votes

    poll.votes.first.cast!(poll.choices.first)
    another_poll.votes.last.cast!(poll.choices.last)

    expect(Vote.cast).to match_array([poll.votes.first, another_poll.votes.last])
  end
end

describe Vote, ".cast_count" do
  it "return the number of cast votes" do
    poll = create :yes_no_poll_with_uncast_votes
    another_poll = create :yes_no_poll_with_uncast_votes

    poll.votes.first.cast!(poll.choices.first)
    another_poll.votes.last.cast!(poll.choices.last)

    expect(Vote.cast_count).to eq(2)
  end
end
