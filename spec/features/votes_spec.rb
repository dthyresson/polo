require 'spec_helper'

describe "Show Vote" do
  it "gets the vote by a short url specific to the voter" do
    question = "Do you forgive me?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first

    visit_vote_by_short_url vote.short_url

    expect(page).to have_content(poll.author_name)
    expect(page).to have_content(question)
    expect(page).to have_content("Yes")
    expect(page).to have_content("No")
    expect(page).to have_link("Yes")
    expect(page).to have_link("No")
    expect(page).to_not have_selector("img")
  end

  it "shows a vote with a photo" do
    poll = create :yes_no_poll_with_photo_and_uncast_votes, question: nil
    vote = poll.votes.first

    visit_vote_by_short_url vote.short_url

    expect(page).to have_content(poll.author_name)
    expect(page).to have_selector("img")
    expect(page).to have_content("Yes")
    expect(page).to have_content("No")
    expect(page).to have_link("Yes")
    expect(page).to have_link("No")
  end

  it "shows a vote with a photo and question" do
    question = "Do you forgive me?"
    poll = create :yes_no_poll_with_photo_and_uncast_votes, question: question
    vote = poll.votes.first

    visit_vote_by_short_url vote.short_url

    expect(page).to have_content(poll.author_name)
    expect(page).to have_selector("img")
    expect(page).to have_content(question)
    expect(page).to have_content("Yes")
    expect(page).to have_content("No")
    expect(page).to have_link("Yes")
    expect(page).to have_link("No")
  end

  it "prevents voting on the poll is over" do
    question = "Do you forgive me?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first

    poll.end!

    visit_vote_by_short_url vote.short_url

    expect(page).to have_content(poll.author_name)
    expect(page).to have_content("Closed")
  end

  it "prevents voting if the vote has already been cast" do
    question = "Do you forgive me?"
    poll = create :yes_no_poll_with_uncast_votes, question: question
    vote = poll.votes.first
    choice = poll.choices.first

    vote.cast!(choice)

    visit_vote_by_short_url vote.short_url

    expect(page).to have_content(poll.author_name)
    expect(page).to have_content(question)
    expect(page).to have_content(choice.title)
    expect(page).to_not have_link(choice.title)
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

