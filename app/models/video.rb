class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews, -> { order("created_at DESC")}
  has_many :queue_items

  before_create :generate_token

  validates_presence_of :title, :description

  def self.search_by_title(search_term)
    return [] if search_term.blank?
    where("title ilike ?", "%#{search_term}%").order("created_at DESC")
  end

  def average_rating
    return "NA" if reviews.empty?
    reviews.reduce(0) { |a, b| a + b.rating } / reviews.size
  end

  private 

  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end