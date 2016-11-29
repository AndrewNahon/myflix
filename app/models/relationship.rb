class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :leader, class_name: "User"

  validates :leader_id, uniqueness: { scope: :follower_id }
end