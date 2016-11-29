class Category < ActiveRecord::Base
  has_many :videos, -> { order("title")}

  validates :name, presence: true

  def recent_videos
    self.videos.reorder("created_at DESC LIMIT 6")
  end
end