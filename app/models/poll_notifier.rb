class PollNotifier < Object
  include Rails.application.routes.url_helpers

  attr_accessor :author_name, :question

  def initialize(poll)
    @poll = poll || NullPoll.new
    @author_name = @poll.author_name
    @question = @poll.question
  end

  def ok_to_sms?(vote)
    return false unless @poll.present?
    return false unless vote.present?
    return false unless vote.has_phone_number?
    true
  end

  def send_sms(vote)
    return unless ok_to_sms?(vote)

    begin
      TWILIO.account.messages.create(from: TWILIO_PHONE_NUMBER, to: vote.phone_number, body: sms_body(vote))
      vote.notify!
    rescue Twilio::REST::RequestError => e
      Raven.capture_exception(e)
    rescue => e
      Raven.capture_exception(e)
    end
  end

  def sms_body(vote)
    "#{author_name} wants to know, \"#{question}\nVote now! #{root_url}#{vote.short_url}\""
  end
end
