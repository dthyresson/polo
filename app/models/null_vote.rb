class NullVote < Object
  def poll
    NullPoll.new
  end

  def choice
    NullChoice.new
  end

  def short_url
    ""
  end

  def votable?
    false
  end

  def cast?
    false
  end
end
