class Api::V1::PollsController < ApiController
  before_action :authenticate, except: [ :create ]

  def close
    @poll = Poll.find(params[:id])
    @poll.end!
    render :show
  end

  def create
    poll_author = author
    poll_photo = photo

    @poll = Poll.new(poll_params)

    @poll.author = poll_author
    @poll.photo = poll_photo if poll_photo

    if @poll.save
      unless Rails.env.test?
        @poll.publish_to_voter_phone_numbers(phone_numbers)
      else
        @poll.delay.publish_to_voter_phone_numbers(phone_numbers)
      end
      render :create
    else
      render :json => { :errors => @poll.errors.full_messages }
    end
  end

  def index
    @polls = Poll.for_author(current_user)
  end

  def show
    @poll = Poll.find(params[:id])

    unless @poll.author == current_user
      render :json => { :errors => "Forbidden"}, status: 403
    end
  end

  private

  def phone_numbers
    params[:poll][:phone_numbers]
  end

  def author
    name = params[:poll][:author_name]
    device_id = params[:poll][:author_device_id]

    params[:poll].delete :author_name
    params[:poll].delete :author_device_id

    device = Device.find_or_create_by({ device_id: device_id })
    author = device.author || Author.create({name: name})
    if device.author
      author.update_attributes({name: name})
    else
      device.update_attribute({author: author})
    end
    author
  end

  def photo
    if params[:poll][:photo_data]
      @photo ||= Paperclip::DataUriAdapter.new(params[:poll][:photo_data])
      params[:poll].delete :photo_data
    end
  end

  def poll_params
    params.require(:poll).permit( :author_name,
                                  :author_device_id,
                                  :question,
                                  :photo_data,
                                 {:choices_attributes => [:title]} )

  end
end
