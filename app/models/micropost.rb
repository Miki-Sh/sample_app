class Micropost < ApplicationRecord
  belongs_to :user    # マイクロポストがユーザーに所属する（belongs_to）関連付け
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png], message: ".jpeg .gif .pngファイルのみアップロードできます" },
                      size:         { less_than: 5.megabytes, message: "5MB以下のファイルのみアップロードできます" }
end