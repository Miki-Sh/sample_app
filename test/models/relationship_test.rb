require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  test "@relationshipは有効か" do
    assert @relationship.valid?
  end

  test "follower_idを要求している" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "followed_idを要求している" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end