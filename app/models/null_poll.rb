class NullPoll < Object
  def author_name
    ""
  end

  def choices
    NullChoice.new
  end

  def has_photo?
    true
  end

  def photo_url(style)
    "/images/#{style}/missing.png"
  end

  def has_question?
    true
  end

  def question
    ""
  end
end
