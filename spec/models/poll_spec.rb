require 'spec_helper'

describe Poll, "associations" do
  it { should belong_to :author }
  it { should have_many :choices }
  it { should have_many(:votes)}
  it { should have_many(:voters).through(:votes) }
end

describe Poll, "validations" do
  it { should accept_nested_attributes_for :choices }
end

describe Poll, "photo attachment validations" do
  it { should have_attached_file(:photo) }
  it { should validate_attachment_content_type(:photo).
                allowing('image/png', 'image/gif', 'image/jpeg').
                rejecting('text/plain', 'text/xml') }
  it { should validate_attachment_size(:photo).
                in(0..2.megabytes) }
end

describe Poll, "validate has either a question or photo" do
  it "has to build a question" do
    poll = create :yes_no_poll, question: "Valid question", photo: nil
    expect(poll).to be_valid
  end

  it "has to have a photo" do
    poll = build :yes_no_poll_with_photo, question: nil
    poll.photo = File.new(File.expand_path("spec/fixtures/marco-polo-600x450.jpg"))
    expect(poll).to be_valid
  end

  it "can have a both question and photo" do
    poll = build :yes_no_poll_with_photo
    poll.photo = File.new(File.expand_path("spec/fixtures/marco-polo-600x450.jpg"))
    expect(poll).to be_valid
  end

  it "is invalid if lacks question or photo" do
    poll = build :yes_no_poll, question: nil, photo: nil
    expect(poll).to_not be_valid
  end
end

describe Poll, "#has_photo" do
  it "checks if there is a poll photo" do
    poll = create :yes_no_poll_with_photo
    expect(poll).to have_photo
  end

  it "checks that the poll photo is there" do
    poll = create :poll, photo: nil
    expect(poll).to_not have_photo
  end
end

describe Poll, "#has_question" do
  it "checks if there is a poll question text" do
    poll = build :poll, question: "Do you forgive me?"
    expect(poll).to have_question
  end

  it "checks that the poll question text is not blank" do
    poll = build :poll, question: ""
    expect(poll).to_not have_question
  end

  it "checks that the poll question text is there" do
    poll = build :poll, question: nil
    expect(poll).to_not have_question
  end
end

describe Poll, ".for_author" do
  it "should return polls for the authoring person" do
    marco = create :author
    polo = create :author
    solo = create :author

    create_list(:poll, 10, author: marco)
    create_list(:poll, 3, author: polo)

    expect(Poll.for_author(marco).count).to eq(10)
    expect(Poll.for_author(polo).count).to eq(3)
    expect(Poll.for_author(solo).count).to eq(0)
  end
end

describe Poll, ".in_progress" do
  it "should return open polls" do

    create_list(:open_poll, 5)
    create_list(:closed_poll, 3)

    expect(Poll.in_progress.count).to eq(5)
  end
end

describe Poll, ".ended" do
  it "should return closed polls" do
    create_list(:open_poll, 5)
    create_list(:closed_poll, 3)

    expect(Poll.ended.count).to eq(3)
  end
end

describe Poll, "#end!" do
  it "should close the poll" do
    open_poll = create(:open_poll)
    expect(open_poll.in_progress?).to be_true
    expect(open_poll.over?).to be_false

    open_poll.end!

    expect(open_poll.over?).to be_true
  end
end

describe Poll, "#publish_to_voters" do
  it "should create voters and votes for a set of phone numbers" do
    phone_numbers = ["16175551212", "12125551212", "12025551212"]
    poll = create(:yes_no_poll_with_phone_numbers, phone_numbers: phone_numbers)

    poll.publish_to_voters

    expect(Voter.count).to eq(3)
    expect(Vote.count).to eq(3)
    expect(poll.votes.count).to eq(3)
    expect(Voter.all.map(&:phone_number)).to match_array(phone_numbers)
  end
end

describe Poll, "#author_name" do
  it "provides the name of the poll author" do
    author_name = "Bob"
    author = create :author, name: author_name
    poll = create(:poll, author: author)
    expect(poll.author_name).to eq(author_name)
  end
end

describe Poll, "#author_device_id" do
  it "provides the device of the poll author" do
    author = create :author_with_device
    author_device_id = author.device_id
    poll = create(:poll, author: author)
    expect(poll.author_device_id).to eq(author_device_id)
  end
end

describe Poll, "#photo_url" do
  context "when poll lacks a photo" do
    it "the photo url is empty" do
      poll = create :yes_no_poll
      expect(poll.photo_url(:medium)).to be_nil
    end
  end

  context "when poll has an uploaded photo" do
    it "uses their photo" do
      poll = create :yes_no_poll_with_photo
      expect(poll.photo_url(:medium)).to eq(poll.photo.url(:medium))
    end
  end
end

describe Poll, "#votes_cast_count" do
  it "returns the number of vote cast on the poll" do
    poll = create :yes_no_poll_with_uncast_votes
    another_poll = create :yes_no_poll_with_uncast_votes
    last_poll = create :yes_no_poll_with_uncast_votes

    poll.votes.first.cast!(poll.choices.first)
    poll.votes.last.cast!(poll.choices.first)
    another_poll.votes.last.cast!(poll.choices.last)

    expect(poll.votes_cast_count).to eq(2)
    expect(another_poll.votes_cast_count).to eq(1)
    expect(last_poll.votes_cast_count).to eq(0)
  end
end

describe Poll, "#ok_to_auto_close?" do
  it "determines if a poll can be automatically closed when all votes have been cast" do
    poll = create :yes_no_poll_with_uncast_votes
    choice = poll.choices.first
    poll.votes.each do |vote|
      vote.cast!(choice)
    end

    expect(poll.reload).to be_ok_to_auto_close
  end

  it "should not be ok to close of no votes cast" do
    poll = create :yes_no_poll_with_uncast_votes

    expect(poll.reload).to_not be_ok_to_auto_close
  end

  it "should not be ok to close if only some votes cast" do
    poll = create :yes_no_poll_with_uncast_votes
    choice = poll.choices.first
    sampling_of_votes = poll.votes.sample(poll.votes_count / 2)

    sampling_of_votes.each do |vote|
      vote.cast!(choice)
    end

    expect(poll.reload).to_not be_ok_to_auto_close
  end
end

describe Poll, "#calculate_popularity!" do
  it "calculates popularity of all choices in the poll based on voting results" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.votes.first.cast!(yes)
    poll.votes.second.cast!(yes)
    poll.votes.last.cast!(no)

    poll.calculate_popularity!

    expect(yes.reload.popularity).to be_within(0.1).of(0.66)
    expect(no.reload.popularity).to be_within(0.1).of(0.33)
  end
end

describe Poll, "#votes_remaining_count" do
  it "figures out how many remaining votes until all in" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.votes.first.cast!(yes)
    poll.votes.second.cast!(yes)

    expect(poll.reload.votes_remaining_count).to eq(1)
  end
end

describe Poll, "#top_choice" do
  it "determines which of the poll's choices has the most votes" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.votes.first.cast!(yes)
    poll.votes.second.cast!(yes)
    poll.votes.last.cast!(no)

    poll.calculate_popularity!

    expect(poll.top_choice).to eq(yes)
  end

  it "handles the case when all have no votes as an undecided" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.calculate_popularity!

    expect(poll.top_choice.title).to eq("Tied")
  end

  it "handles the case when there is a tie" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.votes.first.cast!(yes)
    poll.votes.last.cast!(no)

    poll.calculate_popularity!

    expect(poll.top_choice.title).to eq("Tied")
  end
end

describe Poll, "#tied?" do
  it "is not a tie if a clear winner" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.votes.first.cast!(yes)
    poll.votes.second.cast!(yes)
    poll.votes.last.cast!(no)

    poll.calculate_popularity!

    expect(poll).to_not be_tied
  end

  it "is a tie when no votes case" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.calculate_popularity!

    expect(poll).to be_tied
  end

  it "handles the case when there is a tie" do
    poll = create :yes_no_poll_with_uncast_votes
    yes = poll.choices.first
    no = poll.choices.last

    poll.votes.first.cast!(yes)
    poll.votes.last.cast!(no)

    poll.calculate_popularity!

    expect(poll).to be_tied
  end
end
