require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface
  test "マイクロポストのページネーションが表示される" do
    get root_path
    assert_select 'div.pagination'
  end

  test "無効な投稿でマイクロポストを作成しようとすると、作成されずにエラーが表示される" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
  end

  test "有効な投稿でマイクロポストが作成される" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "自分のプロフィールページにのみ、マイクロポストの削除リンクがある" do
    get user_path(@user)
    assert_select 'a', text: '削除'
  end

  test "自分のマイクロポストのみ削除できる" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "他のユーザーのプロフィールページには、マイクロポストの削除リンクは表示されない" do
    get user_path(users(:archer))
    assert_select 'a', { text: '削除', count: 0 }
  end
end

class MicropostSidebarTest < MicropostsInterface
  test "正しいマイクロポストの投稿数を表示する" do
    get root_path
    assert_match "#{ @user.microposts.count } microposts", response.body
  end

  test "投稿0の場合、複数形で表示される" do
    log_in_as(users(:malory))
    get root_path
    assert_match "0 microposts", response.body
  end

  test "投稿数1の場合、単数形で表示される" do
    log_in_as(users(:lana))
    get root_path
    assert_match "1 micropost", response.body
  end

  class ImageUploadTest < MicropostsInterface
    test "マイクロポストのcreateフォームに画像アップロードがある" do
      get root_path
      assert_select 'input[type = file]'
    end
  
    test "画像をattachできる" do
      cont = "This micropost really ties the room together."
      img  = fixture_file_upload('kitten.jpg', 'image/jpeg')
      post microposts_path, params: { micropost: { content: cont, image: img } }
      assert assigns(:micropost).image.attached?
    end
  end
end