
json.poll do
  json.id poll.id
  json.author do
    json.name poll.author_name
  end

  if poll.has_question?
    json.question poll.question
  end

  if poll.has_photo?
    json.photo_url do
      json.original poll.photo_url(:original)
      json.medium poll.photo_url(:medium)
      json.thumb poll.photo_url(:thumb)
    end
  end

  json.notified_voters_count poll.notified_voters_count
  json.notified_phone_numbers poll.notified_phone_numbers
  json.votes_cast_count poll.votes_cast_count
  json.votes_remaining_count poll.votes_remaining_count
  json.is_closed poll.over?

  if poll.top_choice
    json.top_choice do
      json.title poll.top_choice.title
      json.votes_count poll.top_choice.votes.count
      json.popularity poll.top_choice.popularity
      json.popularity_percentage poll.top_choice.decorate.to_percentage
    end
  end

  json.choices ChoiceDecorator.decorate_collection(poll.choices) do |choice|
    json.choice do
      json.title choice.title
      json.votes_count choice.votes.count
      json.popularity choice.popularity
      json.popularity_percentage choice.to_percentage
    end
  end

  json.votes poll.votes do |vote|
    json.vote do
      json.short_url vote.short_url
      json.voter_phone_number vote.voter_phone_number
      json.choice_title vote.choice.title if vote.cast?
      json.is_cast vote.cast?
      json.is_notified vote.notified?
    end
  end
end
