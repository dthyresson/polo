json.array!(@polls) do |poll|
  json.partial! "poll", :poll => poll
end
