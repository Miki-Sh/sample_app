class Micropost < ApplicationRecord
  belongs_to :user    # マイクロポストがユーザーに所属する（belongs_to）関連付け
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end