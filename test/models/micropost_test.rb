require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
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
end