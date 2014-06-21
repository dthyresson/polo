require 'spec_helper'

describe "Vote API GET" do
  it "gets the vote by a short url specific to the voter" do
    poll = create :yes_no_poll_with_uncast_votes
    vote = poll.votes.first

    headers = { 'CONTENT_TYPE' => 'application/json' }
    get "/v1/votes/#{vote.id}.json"

    expect(response).to be_success
    expect(response.body).to have_json_path("vote/voter_id")
    expect(response.body).to have_json_path("vote/voter_phone_number")
    expect(response.body).to have_json_path("vote/short_url")
    expect(response.body).to have_json_path("vote/choice_id")
  end
end

describe "Vote API PUT" do
  it "casts the vote for a choice based on the short_url" do
    poll = create :yes_no_poll_with_uncast_votes
    vote = poll.votes.first
    expect(vote).to_not be_cast
    choice = poll.choices.first

    headers = { 'CONTENT_TYPE' => 'application/json' }
    put "/v1/votes/#{vote.id}.json?choice_id=#{choice.id}"

    expect(vote.reload).to be_cast

    expect(response).to be_success
    expect(response.body).to have_json_path("vote/voter_id")
    expect(response.body).to have_json_path("vote/voter_phone_number")
    expect(response.body).to have_json_path("vote/short_url")
    expect(response.body).to have_json_path("vote/choice_id")

  end
end
