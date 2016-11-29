class User < ActiveRecord::Base
  include Tokenable
  
  has_many :queue_items
  has_many :reviews
  has_many :following_relationships, class_name: "Relationship", foreign_key: :follower_id
  has_many :leading_relationships, class_name: "Relationship", foreign_key: :leader_id

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :password, presence: true

  has_secure_password validations: false

  def normalize_queue_positions
    queue_items.each_with_index do |item, i|
      item.update({ position: i + 1 })
    end
  end

  def queued_video?(video)
    queue_items.map(&:video).include?(video)
  end

  def follows?(another_user)
    following_relationships.map(&:leader).include?(another_user)
  end

  def can_follow?(another_user)
    !(self == another_user || follows?(another_user))
  end

  def follow(another_user) 
    Relationship.create(leader: another_user, follower: self ) if can_follow?(another_user)
  end
end