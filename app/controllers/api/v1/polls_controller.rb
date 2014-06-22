class Api::V1::PollsController < ApiController
  before_action :authenticate, except: [ :create ]

  def close
    @poll = Poll.find(params[:id])

    if @poll.author == current_user
      @poll.end!
      render :show
    else
      render :json => { :errors => "Forbidden"}, status: 403
    end
  end

  def create
    @poll = Poll.new(poll_params_with_author_info)

    if @poll.save
      @poll.delay.publish_to_voters
      render :create
    else
      render :json => { :errors => @poll.errors.full_messages }, status: 422
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

  def device
    device_id = params[:poll][:author_device_id]
    params[:poll].delete :author_device_id
    @device ||= Device.find_or_create_by({ device_id: device_id })
  end

  def author
    name = params[:poll][:author_name]
    params[:poll].delete :author_name

    if device.author.present?
      device.author.update_attribute(:name, name)
      device.author
    else
      device_author = Author.create({name: name})
      device.update_attribute(:author, device_author)
      device_author
    end
  end

  def poll_params_with_author_info
    poll_author = author
    poll_params.merge({ author: poll_author })
  end

  def poll_params
    params.require(:poll).permit( :author_name,
                                  :author_device_id,
                                  :question,
                                  :photo,
                                 {:choices_attributes => [:title]},
                                 {:phone_numbers => []} )

  end
end
