class PollNotifier < Object

  attr_accessor :author_name, :question

  def initialize(poll)
    @poll = poll
    @author_name = poll.author_name
    @question = poll.question
  end

  def send_sms(vote)
    return unless @poll.present?
    return unless vote.present?
    phone_number = vote.phone_number
    return unless phone_number.present?
    begin
      TWILIO.account.messages.create(
        from: TWILIO_PHONE_NUMBER,
        to: phone_number,
        body: "#{author_name} wants to know, \"#{question}\""
      )
      vote.notify!
    rescue Twilio::REST::RequestError => e
      # send this to airbrake?
      # delete the vote and remove the phone number?
      puts e.message
    rescue => e
      # just eat it. eat it. eat it.
    end
  end
end
