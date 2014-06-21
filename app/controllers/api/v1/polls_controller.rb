class Api::V1::PollsController < ApiController

  def close
    @poll = Poll.find(params[:id])
    @poll.end!
    render :show
  end

  def create
    poll_author = author
    @poll = Poll.new(poll_params)
    @poll.author = poll_author

    if @poll.save
      @poll.publish_to_voter_phone_numbers(phone_numbers)
      render :create
    else
      render :json => { :errors => @poll.errors.full_messages }
    end
  end

  def index
    @polls = Poll.all
  end

  def show
    @poll = Poll.find(params[:id])
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

  def poll_params
    params.require(:poll).permit(:author_name,
                                  :author_device_id,
                                  :question,
                                 {:choices_attributes => [:title]})

  end
end
