require 'spec_helper'

describe Poll, "associations" do
  it { should belong_to :author }
  it { should have_many :choices }
  it { should have_many(:votes)}
  it { should have_many(:voters).through(:votes) }
end

describe Poll, "validations" do
  it { should accept_nested_attributes_for :choices }
  it { should validate_presence_of :phone_numbers }
  it { should validate_presence_of :author }
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
    poll = create :yes_no_poll, photo: nil
    expect(poll).to_not have_photo
  end
end

describe Poll, "#has_question" do
  it "checks if there is a poll question text" do
    poll = build :yes_no_poll, question: "Do you forgive me?"
    expect(poll).to have_question
  end

  it "checks that the poll question text is not blank" do
    poll = build :yes_no_poll, question: ""
    expect(poll).to_not have_question
  end

  it "checks that the poll question text is there" do
    poll = build :yes_no_poll, question: nil
    expect(poll).to_not have_question
  end
end

describe Poll, ".for_author" do
  it "should return polls for the authoring person" do
    marco = create :author
    polo = create :author
    solo = create :author

    create_list(:yes_no_poll, 10, author: marco)
    create_list(:yes_no_poll, 3, author: polo)

    expect(Poll.for_author(marco).count).to eq(10)
    expect(Poll.for_author(polo).count).to eq(3)
    expect(Poll.for_author(solo).count).to eq(0)
  end
end

describe Poll, ".ordered" do
  it "should have newer polls come before older ones based on when last updated" do
    polls = create_list(:poll, 3)

    oldest_poll = Poll.second
    oldest_poll.update_attribute(:updated_at, 2.months.ago)

    middle_poll = Poll.last
    middle_poll.update_attribute(:updated_at, 1.months.ago)

    most_recent_poll = Poll.first
    most_recent_poll.update_attribute(:updated_at, 1.hour.ago)

    expect(Poll.ordered.count).to eq(3)
    expect(Poll.ordered).to eq([most_recent_poll, middle_poll, oldest_poll])
  end
end

describe Poll, ".recent" do
  it "should return recently created polls" do
    polls = create_list(:poll, 2)
    older_polls = create_list(:poll_from_last_year, 5)

    expect(Poll.recent.count).to eq(2)
    expect(Poll.recent).to match_array(polls)
  end
end

describe Poll, ".in_progress" do
  it "should return open polls" do

    open_polls = create_list(:open_poll, 5)
    closed_polls = create_list(:closed_poll, 3)

    expect(Poll.in_progress.count).to eq(5)
    expect(Poll.in_progress).to match_array(open_polls)
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
    expect(open_poll).to be_in_progress
    expect(open_poll).to_not be_over

    open_poll.end!

    expect(open_poll).to be_over
  end
end

describe Poll, "#open!" do
  it "should open a closed poll" do
    closed_poll = create(:closed_poll)
    expect(closed_poll).to be_over
    expect(closed_poll).to be_over
    expect(closed_poll).to_not be_in_progress

    closed_poll.open!

    expect(closed_poll).to be_in_progress
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
    poll = create(:yes_no_poll, author: author)
    expect(poll.author_name).to eq(author_name)
  end
end

describe Poll, "#author_device_id" do
  it "provides the device of the poll author" do
    author = create :author_with_device
    author_device_id = author.device_id
    poll = create(:yes_no_poll, author: author)
    expect(poll.author_device_id).to eq(author_device_id)
  end
end

describe Poll, "#photo_url" do
  context "when poll lacks a photo" do
    it "the photo url is the missage default" do
      poll = create :yes_no_poll
      expect(poll.photo_url(:medium)).to eq("/images/medium/missing.png")
    end
  end

  context "when poll has an uploaded photo" do
    it "uses their photo" do
      poll = create :yes_no_poll_with_photo
      expect(poll.photo_url(:medium)).to eq(poll.photo.url(:medium))
    end
  end
end

describe Poll, "#vote_cast!" do
  it "should make a call to calculate popularity" do
    poll = build :poll
    poll.stub(:calculate_popularity!)
    poll.vote_cast!
    expect(poll).to have_received(:calculate_popularity!)
  end

  it "should make a call to end if all votes cast" do
    poll = build :yes_no_poll
    votes = build :vote, choice: poll.choices.first

    poll.stub(:end!)
    poll.vote_cast!
    expect(poll).to have_received(:end!)
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

describe Poll, "#notified_voters" do
  it "returns a list of voters who have been notifed to vote" do
    poll = create :yes_no_poll_with_notified_voters
    voters = poll.voters
    expect(poll.notified_voters).to match_array(voters)
  end
end

describe Poll, "#notified_voters_count" do
  it "counts how many voters have been notifed to vote" do
    poll = create :yes_no_poll_with_notified_voters
    expect(poll.notified_voters_count).to eq(3)
  end
end

describe Poll, "#notified_phone_numbers" do
  it "returns a list of voter phone_numbers that have been sent notificatons to vote" do
    poll = create :yes_no_poll_with_some_notified_voters
    expect(poll.notified_voters_count).to eq(2)
    expect(poll.notified_phone_numbers).to match_array(["16175550002", "12025550004"])
  end
end

describe Poll, "#notified_formatted_phone_numbers" do
  it "returns a formatted list of voter phone_numbers that have been sent notificatons to vote" do
    poll = create :yes_no_poll_with_some_notified_voters
    expect(poll.notified_formatted_phone_numbers).to match_array(["+1-617-555-0002", "+1-202-555-0004"])
  end
end

describe Poll, "#has_phone_numbers?" do
  it "determines that phone numbers are set to notify as voters" do
    poll = create :poll, phone_numbers: ["16175551212", "12125551212"]
    expect(poll).to have_phone_numbers
  end
end

describe Poll, "save callback to normalize phone numbers" do
  it "makes the phone numbers nice when saving the poll" do
    poll = create :poll, phone_numbers: ["6175551212", "2125551212", "+1-415-555-1212", "(415) 555-5555", "(202)5559999"]
    expect(poll.reload.phone_numbers).to eq(["16175551212", "12125551212", "14155551212", "14155555555", "12025559999"])
  end

  it "removes bad phone numbers saving the poll" do
    poll = create :poll, phone_numbers: ["junk", "2125551212", "+1-415-555-1212", "(415) 555-5555", "00000"]
    expect(poll.reload.phone_numbers).to eq(["12125551212", "14155551212", "14155555555"])
  end

end
