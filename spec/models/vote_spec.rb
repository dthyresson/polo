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

  it "cannot cast a vote for a choice if poll is closed" do
    poll = create :yes_no_poll_with_uncast_votes

    yes_choice = poll.choices.first
    no_choice = poll.choices.last
    vote = poll.votes.first

    poll.end!

    vote.cast!(yes_choice)

    expect(vote).to_not be_cast
    expect(vote.cast_at).to_not be_present
    expect(vote.choice).to be_nil
  end

  it "auto closes a poll when all votes cast" do
    poll = create :yes_no_poll_with_uncast_votes
    choice = poll.choices.first
    poll.votes.each do |vote|
      vote.cast!(choice)
    end

    expect(poll).to be_over
  end

  it "won't close a poll if only some votes cast" do
    poll = create :yes_no_poll_with_uncast_votes
    choice = poll.choices.first
    vote = poll.votes.first
    vote.cast!(choice)

    expect(poll).to_not be_over
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

describe Vote, "#votable?" do
  it "checks if a vote can be cast as long as the poll is in progress and vote not already cast" do
    question = "Do you like ice cream?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first
    expect(vote).to be_votable
  end

  it "vote cannot be cast if poll is closed" do
    question = "Do you like ice cream?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first
    poll.end!
    expect(vote).to_not be_votable
  end

  it "vote cannot be cast if vote cast" do
    question = "Do you like ice cream?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first
    vote.cast!(poll.choices.first)
    expect(vote).to_not be_votable
  end

  it "vote cannot be cast if poll is closed and vote cast" do
    question = "Do you like ice cream?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first
    vote.cast!(poll.choices.first)
    poll.end!
    expect(vote).to_not be_votable
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

describe Vote, ".notified" do
  it "returns only those votes whose voters have been notified (ie, via sms)" do
    notified_votes = create_list(:notified_vote, 2)
    vote = create :vote

    expect(Vote.notified).to match_array(notified_votes)
  end
end

describe Vote, "#notify!" do
  it "marks the vote to indicate that the voter has been notified" do
    vote = create :vote
    vote.notify!
    expect(vote).to be_notified
  end
end

describe Vote, "#notified?" do
  it "determines that the voter has not been notified" do
    vote = create :vote
    expect(vote).to_not be_notified
  end

  it "determines if the voter has been notified" do
    vote = create :notified_vote
    expect(vote).to be_notified
  end
end

describe Vote, "phone_number" do
  it "returns the phone_number of the voter" do
    phone_number = "14155551212"
    voter = create :voter, phone_number: phone_number
    vote = create :vote, voter: voter
    expect(vote.phone_number).to eq(phone_number)
  end
end
