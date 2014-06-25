require 'spec_helper'

describe PollNotifier, "#send_sms" do
  it "can send sms messages" do
    poll = build :poll
    poll_notifier = PollNotifier.new(poll)
    expect(poll_notifier).to respond_to(:send_sms)
  end
end

describe PollNotifier, "#ok_to_sms?" do
  it "checks if the vote is ok to sent as a SMS" do
    poll = create :yes_no_poll_with_uncast_votes
    vote = poll.votes.first
    poll_notifier = PollNotifier.new(poll)
    expect(poll_notifier.ok_to_sms?(vote)).to be_true
  end

  it "is not ok the send a SMS if there is no poll" do
    poll_notifier = PollNotifier.new(nil)
    expect(poll_notifier.ok_to_sms?(nil)).to be_false
  end

  it "is not ok the send a SMS if there is no vote" do
    poll = create :yes_no_poll_with_uncast_votes
    poll_notifier = PollNotifier.new(poll)
    expect(poll_notifier.ok_to_sms?(nil)).to be_false
  end

  it "is not ok the send a SMS if there is no voter phone number" do
    poll = create :yes_no_poll_with_uncast_votes
    voter = build :voter, phone_number: nil
    vote = build :vote, voter: voter
    poll_notifier = PollNotifier.new(poll)
    expect(poll_notifier.ok_to_sms?(vote)).to be_false
  end
end

describe PollNotifier, "#sms_body" do
  it "formats the sms body message" do
    poll = create :yes_no_poll_with_uncast_votes
    vote = poll.votes.first
    poll_notifier = PollNotifier.new(poll)

    expect(poll_notifier.sms_body(vote)).to include(poll.question)
    expect(poll_notifier.sms_body(vote)).to include(poll.author_name)
    expect(poll_notifier.sms_body(vote)).to include(vote.short_url)
  end
end
