class VotesController < ApplicationController
  def show
    @vote = Vote.find_by_short_url(params[:short_url])
    @poll = @vote.poll
    @choices = @poll.choices.ordered
  end

  def update
    @vote = Vote.find(params[:id])
    choice = Choice.find(params[:choice_id])
    @vote.cast!(choice) if choice
    redirect_to vote_short_url_path(@vote.short_url)
  end
end
