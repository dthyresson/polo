module Features
  def visit_vote_by_short_url(short_url)
    visit vote_short_url_path(short_url)
  end
end
