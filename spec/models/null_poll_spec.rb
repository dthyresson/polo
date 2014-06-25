require 'spec_helper'

describe NullPoll, "author_name" do
  it "has an empty author_name" do
    null_poll = NullPoll.new
    expect(null_poll.author_name).to be_empty
  end
end

describe NullPoll, "choices" do
  it "has an empty set of choices" do
    null_poll = NullPoll.new
    expect(null_poll.choices).to be_a(NullChoice)
  end
end

describe NullPoll, "has_photo?" do
  it "does have a photo" do
    null_poll = NullPoll.new
    expect(null_poll.has_photo?).to be_true
  end
end

describe NullPoll, "photo_url" do
  it "returns a missing photo rul" do
    null_poll = NullPoll.new
    expect(null_poll.photo_url(:medium)).to eq("/images/medium/missing.png")
  end
end

describe NullPoll, "has_question?" do
  it "does have a question" do
    null_poll = NullPoll.new
    expect(null_poll.has_question?).to be_true
  end
end

describe NullPoll, "question" do
  it "has a blank question" do
    null_poll = NullPoll.new
    expect(null_poll.question).to eq("")
  end
end
