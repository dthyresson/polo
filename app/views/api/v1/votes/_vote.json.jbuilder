json.cache! vote do
  json.vote do
    json.voter_id vote.id
    json.voter_id vote.voter_id
    json.voter_phone_number vote.voter_phone_number
    json.short_url vote.short_url
    json.choice_id vote.choice_id
    json.choice_title vote.choice_title
    json.is_cast vote.cast?
  end
end
