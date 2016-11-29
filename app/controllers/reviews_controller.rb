class ReviewsController < ApplicationController 
  before_filter :require_user

  def create 
    @user = current_user
    @video = Video.find params["video_id"] 
    @review = Review.new(
                          content: params["review"]["content"], 
                          rating: params["review"]["rating"], 
                          user: @user,
                          video: @video )

    if @review.save 
      redirect_to video_path(@video), notice: "Your review was created."
    else
      @reviews = @video.reviews
      render "videos/show"
      flash[:error] = "Your review could not be created."
    end
  end
end