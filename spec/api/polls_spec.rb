require 'spec_helper'

describe "Poll API GET" do
  it "returns unauthorized if you pass an invalid authorization token" do
    bad_device_id = SecureRandom.hex(20)
    author = create :author_with_device
    create_list(:yes_no_poll, 10, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(bad_device_id) }
    get '/v1/polls.json', nil, headers

    expect(response).to_not be_success
    expect(response.status).to eq(401)
  end

  it "returns no polls if you haven't authored any polls" do
    author_without_polls = create :author_with_device
    author = create :author_with_device
    create_list(:yes_no_poll, 10, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author_without_polls.device_id) }
    get '/v1/polls.json', nil, headers

    expect(response).to be_success
    expect(response.body).to eq("")
    expect(response.status).to eq(204)
  end

  it "gets a list of my polls" do
    author = create :author_with_device
    create_list(:yes_no_poll, 10, author: author)

    another_author = create :author_with_device
    create_list(:yes_no_poll, 2, author: another_author)

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
    poll = create(:yes_no_poll, author: author)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    get "/v1/polls/#{poll.id}.json", nil, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/id")
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to have_json_path("poll/choices/0/title")
  end

  it "is forbidden to get someone else's poll" do
    forbidden_author = create :author_with_device
    author = create :author_with_device
    poll = create(:yes_no_poll, author: author)

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
    expect(response.body).to have_json_path("poll/choices/0/title")
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
    expect(response.body).to have_json_path("poll/choices/0/title")
    expect(response.body).to have_json_path("poll/votes")
    expect(response.body).to have_json_path("poll/votes/0")
    expect(response.body).to have_json_path("poll/votes/0/short_url")
  end

  it 'gets my poll with cast votes' do
    author = create :author_with_device
    poll = create(:yes_no_poll_with_uncast_votes, author: author)

    vote = poll.votes.first
    vote.cast!(poll.choices.first)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    get "/v1/polls/#{poll.id}.json", nil, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to have_json_path("poll/choices/0")
    expect(response.body).to have_json_path("poll/choices/0/title")
    expect(response.body).to have_json_path("poll/votes")
    expect(response.body).to have_json_path("poll/votes/0")
    expect(response.body).to have_json_path("poll/votes/0/short_url")
    expect(response.body).to have_json_path("poll/votes/0/is_cast")
    expect(response.body).to include("\"is_cast\":true")
  end

  it 'gets my poll with top choice' do
    author = create :author_with_device
    poll = create(:yes_no_poll_with_uncast_votes, author: author)

    vote = poll.votes.first
    vote.cast!(poll.choices.first)

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    get "/v1/polls/#{poll.id}.json", nil, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/top_choice")
    expect(response.body).to have_json_path("poll/top_choice/title")
  end
end

describe "Poll API POST" do
  it 'creates a new open poll with two choices' do

    stub_request(:post, "https://AC2fbca92xxxxxxe45a5dedbe414bec340:4ae82bb084f1d99cf7b6c82c14baxxxx@api.twilio.com/2010-04-01/Accounts/AC2fbca92xxxxxxe45a5dedbe414bec340/Messages.json").
                 to_return(:status => 200, :body => "", :headers => {})

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
  end

  it "creates a poll with a photo and question" do
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

  it "creates a poll with voter phone numbers" do
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

  it "cannot create a poll without phone numbers" do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_question_but_no_phone_numbers.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response.status).to eq(422)
    expect(parse_json(response.body)['errors']).to include("Phone numbers can't be blank")
  end

  it "cannot create a poll without a question or a photo" do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_no_question_or_photo.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response.status).to eq(422)
    expect(parse_json(response.body)['errors']).to include("Need to ask a question or show a photo")
  end

  it "does not create voters with bad phone numbers" do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_some_bad_phone_numbers.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response).to be_success
    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/question")
    expect(response.body).to have_json_path("poll/choices")
    expect(response.body).to have_json_path("poll/votes")

    poll = Poll.last
    expect(poll).to be

    expect(Voter.count).to eq(1)
    expect(Vote.count).to eq(1)
    expect(poll.votes.count).to eq(1)
    expect(Voter.all.map(&:phone_number)).to match_array(["16175551212"])
  end

  xit "cannot create a poll with too large an image" do
    # this fixture may be silly
    # will revist when a final image attachment size is determined
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_3MB_image.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response.status).to eq(422)
    expect(parse_json(response.body)['errors']).to include("Choices can't be blank")
  end

  xit "cannot create a poll without choices" do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_no_choices.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response.status).to eq(422)
    expect(parse_json(response.body)['errors']).to include("Choices can't be blank")
  end

  it "cannot create a poll without an author" do
    poll_json = File.read(Rails.root.join("spec", "fixtures", "poll_with_no_author.json"))

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "/v1/polls/", poll_json, headers

    expect(response.status).to eq(422)
    expect(parse_json(response.body)['errors']).to include("Author name can't be blank")
  end
end

describe "Poll API PUT to close" do
  it 'closes my poll' do
    author = create :author_with_device
    poll = create(:yes_no_poll, author: author)
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
    poll = create(:yes_no_poll, author: author)
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
    poll = create(:yes_no_poll, author: author)
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

describe "Poll API PUT to open" do
  it 'opens a closed poll' do
    author = create :author_with_device
    poll = create(:yes_no_poll, author: author, closed_at: 2.days.ago)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to be_over

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    put "/v1/polls/#{poll.id}/open.json", nil, headers

    expect(response.status).to eq(200)
    poll = Poll.last
    expect(poll).to be_in_progress
  end

  it "will not open someone else's poll" do
    someone_else = create :author_with_device

    author = create :author_with_device
    poll = create(:yes_no_poll, author: author, closed_at: 2.days.ago)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to be_over

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(someone_else.device_id) }

    put "/v1/polls/#{poll.id}/open.json", nil, headers

    expect(response.status).to eq(403)
    poll = Poll.last
    expect(poll).to be_over
  end
end

describe "Poll API PUT to remind" do
  it 'reminds an unreminded poll' do
    author = create :author_with_device
    poll = create(:yes_no_poll, author: author, closed_at: 2.days.ago)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to_not be_reminded

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(author.device_id) }
    put "/v1/polls/#{poll.id}/remind.json", nil, headers

    expect(response.status).to eq(200)
    expect(response.body).to have_json_path("poll/is_reminded")
    expect(parse_json(response.body)['poll']['is_reminded']).to be_true

    poll = Poll.last
    expect(poll).to be_reminded
  end

  it "will not remind someone else's poll" do
    someone_else = create :author_with_device

    author = create :author_with_device
    poll = create(:yes_no_poll, author: author, closed_at: 2.days.ago)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to_not be_reminded

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(someone_else.device_id) }

    put "/v1/polls/#{poll.id}/remind.json", nil, headers

    expect(response.status).to eq(403)
    poll = Poll.last
    expect(poll).to_not be_reminded
  end


  it "is unauthorized if try to open with a bad device id" do
    bad_device_id = SecureRandom.hex(20)

    author = create :author_with_device
    poll = create(:yes_no_poll, author: author, closed_at: 2.days.ago)
    choices = create_list(:choice, 2, poll: poll)

    expect(poll).to_not be_reminded

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(bad_device_id) }

    put "/v1/polls/#{poll.id}/remind.json", nil, headers

    expect(response.status).to eq(401)
    poll = Poll.last
    expect(poll).to_not be_reminded
  end
end

describe "Poll API pagination" do
  it "returns a default of 10 polls per page when no page reqeusted" do
    device_author = create :author_with_device
    20.times do
      create :yes_no_poll_with_uncast_votes, author: device_author
    end

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(device_author.device_id) }
    get '/v1/polls.json', nil, headers

    polls = parse_json(response.body)

    expect(response.headers['Link']).to_not be_empty
    expect(polls.size).to eq(10)
  end

  it "returns 10 polls per page when a page is reqeusted" do
    device_author = create :author_with_device
    20.times do
      create :yes_no_poll_with_uncast_votes, author: device_author
    end

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(device_author.device_id) }
    get '/v1/polls.json?page=1', nil, headers

    polls = parse_json(response.body)

    expect(response.headers['Link']).to_not be_empty
    expect(polls.size).to eq(10)
  end

  it "returns a link to the next page of results" do
    device_author = create :author_with_device
    20.times do
      create :yes_no_poll_with_uncast_votes, author: device_author
    end

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(device_author.device_id) }
    get '/v1/polls.json', nil, headers

    expect(response.headers['Link']).to_not be_empty
    expect(response.headers['Link']).to include("polls")
    expect(response.headers['Link']).to include("next")
  end

  it "doesn't return a link to the next page of results when on last page" do
    device_author = create :author_with_device
    20.times do
      create :yes_no_poll_with_uncast_votes, author: device_author
    end

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(device_author.device_id) }
    get '/v1/polls.json?page=2', nil, headers

    polls = parse_json(response.body)

    expect(response.headers['Link']).to be_nil
    expect(polls.size).to eq(10)
  end

  it "returns a custom page per size" do
    device_author = create :author_with_device
    10.times do
      create :yes_no_poll_with_uncast_votes, author: device_author
    end

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(device_author.device_id) }
    get '/v1/polls.json?per=3', nil, headers

    polls = parse_json(response.body)

    expect(response.headers['Link']).to be
    expect(polls.size).to eq(3)
  end

  it "returns no content when requesting a page beyond last page" do
    device_author = create :author_with_device
    20.times do
      create :yes_no_poll_with_uncast_votes, author: device_author
    end

    headers = { "CONTENT_TYPE" => "application/json",
                'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(device_author.device_id) }
    get '/v1/polls.json?page=3', nil, headers
    expect(response.status).to eq(204)
  end
end
