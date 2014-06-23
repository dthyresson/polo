require 'spec_helper'

describe PollNotifier, "method" do
  it "can send sms messages" do
    poll = build :poll
    expect(PollNotifier.new(poll)).to respond_to(:send_sms)
  end
end
