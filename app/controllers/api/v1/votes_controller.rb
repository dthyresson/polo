class Api::V1::VotesController < ApiController
  before_action :authenticate

  def show
    @vote = Vote.find(params[:id])
  end

  def update
    @vote = Vote.find(params[:id])
    choice = Choice.find(params[:choice_id])
    @vote.cast!(choice) if choice
    render :show
  end
end
