require 'spec_helper'

describe "Poll API GET" do
  it "returns no polls if you are not the author" do
    bad_device_id = SecureRandom.hex(20)
    author = create :author_with_device
    create_list(:poll, 10, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(bad_device_id) }
    get '/v1/polls.json', nil, headers

    expect(response).to_not be_success

  end

  it "gets a list of my polls" do
    author = create :author_with_device
    create_list(:poll, 10, author: author)

    another_author = create :author_with_device
    create_list(:poll, 2, author: another_author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }

    get '/v1/polls.json', nil, headers

    expect(response).to be_success
    expect(response.status).to eq(200)

    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
  end

  it 'gets one of my polls' do
    author = create :author_with_device
    poll = create(:poll, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    get "/v1/polls/#{poll.id}.json", nil, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to_not have_json_path("poll/choices/0/choice/title")
  end

  it "is forbidden to get someone else's poll" do
    forbidden_author = create :author_with_device
    author = create :author_with_device
    poll = create(:poll, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(forbidden_author.device_id) }
    get "/v1/polls/#{poll.id}.json", nil, headers
    expect(response.status).to eq(403)
  end

  it 'gets my poll with choices' do
    author = create :author_with_device
    poll = create(:yes_no_poll, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    get "/v1/polls/#{poll.id}.json", nil, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to have_json_path("poll/choices/0")
    expect(response.body).to have_json_path("poll/choices/0/choice/title")
  end

  it 'gets my poll with uncast votes' do
    author = create :author_with_device
    poll = create(:yes_no_poll_with_uncast_votes, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    get "/v1/polls/#{poll.id}.json", nil, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to have_json_path("poll/choices/0")
    expect(response.body).to have_json_path("poll/choices/0/choice/title")
    expect(response.body).to have_json_path("poll/votes")
    expect(response.body).to have_json_path("poll/votes/0")
    expect(response.body).to have_json_path("poll/votes/0/vote/voter_id")
  end
end

describe "Poll API POST" do
  it 'creates a new open poll with two choices' do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_question.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")

    poll = Poll.last
    expect(poll).to be
    expect(poll.choices.count).to eq(2)
    # expect(poll.author).to eq(author)
    # expect(poll.author.device_id).to eq(author.device_id)
  end

  it "creates a post with a photo and question" do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_question_and_photo.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to have_json_path("poll/photo_url/original")
    expect(response.body).to have_json_path("poll/photo_url/medium")
    expect(response.body).to have_json_path("poll/photo_url/thumb")

    poll_with_photo = Poll.last

    expect(poll_with_photo.author_name).to eq("Britney Lee")
    expect(poll_with_photo.question).to eq("Will you go out with me?")
    expect(poll_with_photo.choices.map(&:title)).to match_array(["Yes", "No"])
    expect(poll_with_photo).to have_photo
    expect(poll_with_photo.photo_url(:medium)).to eq(poll_with_photo.photo.url(:medium))
  end

  it "creates a post with voter phone numbers" do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_question.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to have_json_path("poll/votes")

    poll = Poll.last
    expect(poll).to be

    expect(Voter.count).to eq(3)
    expect(Vote.count).to eq(3)
    expect(poll.votes.count).to eq(3)
    expect(Voter.all.map(&:phone_number)).to match_array(["16175551212", "12125551212", "12025551212"])
  end
end

describe "Poll API PUT to close" do
  it 'closes my poll' do
    author = create :author_with_device
    poll = create(:poll, author: author)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to be_in_progress

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    put "/v1/polls/#{poll.id}/close.json", nil, headers

    expect(response.status).to eq(200)
    poll = Poll.last
    expect(poll).to be_over
  end

  it "will not close someone else's poll" do
    someone_else = create :author_with_device

    author = create :author_with_device
    poll = create(:poll, author: author)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to be_in_progress

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(someone_else.device_id) }

    put "/v1/polls/#{poll.id}/close.json", nil, headers

    expect(response.status).to eq(403)
    poll = Poll.last
    expect(poll).to be_in_progress
  end

  it "is unauthorized if try to close with a bad device id" do
    bad_device_id = SecureRandom.hex(20)

    author = create :author_with_device
    poll = create(:poll, author: author)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to be_in_progress

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(bad_device_id) }

    put "/v1/polls/#{poll.id}/close.json", nil, headers

    expect(response.status).to eq(401)
    poll = Poll.last
    expect(poll).to be_in_progress
  end

end
