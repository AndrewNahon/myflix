
class QueueItemsController < ApplicationController

  before_filter :require_user 

  def index 
    @queue_items = current_user.queue_items
  end

  def create 
    video = Video.find(params[:video_id])
    queue_video(video)

    redirect_to my_queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id])
    queue_item.destroy if queue_item.user == current_user
    current_user.normalize_queue_positions
    redirect_to my_queue_path
  end

  def update
    begin 
      update_queue_items
      current_user.normalize_queue_positions
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Invalid position numbers."
      redirect_to my_queue_path
      return 
    end
    redirect_to my_queue_path
  end

  private

  def queue_video(video)
    QueueItem.create(video: video, user: current_user, position: next_position) unless current_user_queued_video?(video)
  end

  def next_position 
    current_user.queue_items.size + 1
  end

  def current_user_queued_video?(video) 
    current_user.queue_items.map(&:video).include?(video)
  end

  def update_queue_items
    ActiveRecord::Base.transaction do 
      params[:queue_items].each do |item|
        queue_item = QueueItem.find(item[:id])
        queue_item.update_attributes!(position: item[:position], rating: item[:rating]) if current_user == queue_item.user
      end
    end
  end
end