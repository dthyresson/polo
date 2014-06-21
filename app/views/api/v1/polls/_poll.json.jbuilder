json.cache! poll do
  json.poll do
    json.question poll.question
    json.photo_url_original poll.photo_url(:original)
    json.photo_url_medium poll.photo_url(:medium)
    json.photo_url_thum poll.photo_url(:thumb)
    json.choices poll.choices do |choice|
                    json.choice do
                      json.title choice.title
                    end
                 end

    json.votes poll.votes do |vote|
                    json.vote do
                      json.voter_id vote.voter_id
                      json.voter_phone_number vote.voter_phone_number
                      json.short_url vote.short_url
                    end
                 end
  end
end
