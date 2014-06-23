class PollNotifier < Object

  attr_accessor :author_name, :question

  def initialize(poll)
    @poll = poll
    @author_name = poll.author_name
    @question = poll.question
  end

  def send_sms(phone_number)
    return unless @poll.present?
    unless Rails.env.test?
      begin
        TWILIO.account.messages.create(
          from: TWILIO_PHONE_NUMBER,
          to: phone_number,
          body: "#{author_name} wants to know, \"#{question}\""
        )
      rescue Twilio::REST::RequestError => e
        # send this to airbrake?
        # delete the vote and remove the phone number?
        puts e.message
      end
    end
  end
end
