require 'spec_helper'

describe "Show Vote" do
  it "gets the vote by a short url specific to the voter" do
    question = "Do you forgive me?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first

    visit_vote_by_short_url vote.short_url

    expect(page).to have_content(question)
    expect(page).to have_content("Yes")
    expect(page).to have_content("No")
  end
end

describe "Cast Vote" do
  it "casts a vote" do
    question = "Do you forgive me?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first

    visit_vote_by_short_url vote.short_url

    expect(page).to have_content(question)
    expect(page).to have_content("Yes")
    expect(page).to have_content("No")

    click_link "Yes"

    poll.reload
    vote.reload

    expect(vote).to be_cast
    expect(poll.votes_cast_count).to eq(1)
  end
end

