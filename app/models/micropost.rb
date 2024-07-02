class Micropost < ApplicationRecord
  belongs_to :user    # マイクロポストがユーザーに所属する（belongs_to）関連付け
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end