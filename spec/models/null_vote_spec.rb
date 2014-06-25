require 'spec_helper'

describe NullVote, "short_url" do
  it "has an empty short url" do
    null_vote = NullVote.new
    expect(null_vote.short_url).to be_empty
  end
end

describe NullVote, "poll" do
  it "has a poll" do
    null_vote = NullVote.new
    expect(null_vote.poll).to be_a(NullPoll)
  end
end

describe NullVote, "choice" do
  it "has a choice" do
    null_vote = NullVote.new
    expect(null_vote.choice).to be_a(NullChoice)
  end
end

describe NullVote, "votable?" do
  it "is not votable" do
    null_vote = NullVote.new
    expect(null_vote).to_not be_votable
  end
end

describe NullVote, "cast?" do
  it "is not cast" do
    null_vote = NullVote.new
    expect(null_vote).to_not be_cast
  end
end
