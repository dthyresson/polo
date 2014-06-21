json.cache! poll do
  json.poll do
    json.question poll.question
    json.photo_url_original poll.photo_url(:original)
    json.photo_url_medium poll.photo_url(:medium)
    json.photo_url_thumb poll.photo_url(:thumb)
    json.votes_cast_count poll.votes_cast_count
    json.votes_remaining_count poll.votes_remaining_count
    json.is_closed poll.over?
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
                      json.voter_id vote.voter_id
                      json.voter_phone_number vote.voter_phone_number
                      json.short_url vote.short_url
                      json.choice_title vote.choice.title if vote.cast?
                    end
                 end
  end
end
