require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "micropostは有効である" do
    assert @micropost.valid?
  end

  test "ユーザーIDは存在する" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "contentは存在する" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "contentは140文字以内である" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "データベース上の最初のマイクロポストが、fixture内のマイクロポストであるmost_recentと同じである" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  test "ユーザーが削除されたときに、そのユーザーに紐付いたマイクロポストも一緒に削除される" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end