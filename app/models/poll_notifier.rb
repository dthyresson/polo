class PollNotifier < Object
  include Rails.application.routes.url_helpers

  attr_accessor :author_name, :question

  def initialize(poll)
    @poll = poll || NullPoll.new
    @author_name = @poll.author_name
    @question = @poll.question
  end

  def ok_to_message?(vote)
    return false unless @poll
    return false unless vote
    return false unless vote.has_phone_number?
    true
  end

  def notify(vote)
    return false unless ok_to_message?(vote)
    sms(vote.phone_number, notify_message_text(vote))
  end

  def remind(vote)
    return false unless ok_to_message?(vote)
    sms(vote.phone_number, reminder_message_text(vote))
  end

  def sms(phone_number, message_body)
    begin
      TWILIO.account.messages.create(from: TWILIO_PHONE_NUMBER, to: phone_number, body: message_body)
    rescue Twilio::REST::RequestError => e
      Raven.capture_exception(e)
    rescue => e
      Raven.capture_exception(e)
    end
    true
  end

  def notify_message_text(vote)
    "#{author_name} wants to know, \"#{question}\nVote now! #{root_url}#{vote.short_url}\""
  end

  def reminder_message_text(vote)
    "#{author_name} wants to remind you, \"#{question}\nVote now! #{root_url}#{vote.short_url}\""
  end
end
