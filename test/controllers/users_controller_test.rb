require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "show displays liked artists as image tiles with their name" do
    user = User.create!(email: "likes@example.com", password: "password123", username: "likes-user", birthdate: 20.years.ago)
    artist_user = User.create!(email: "artist@example.com", password: "password123", username: "liked-artist", birthdate: 25.years.ago)
    artist_profile = artist_user.create_artist_profile!(display_name: "Ink Master")
    artist_profile.portfolio_items.create!(image_url: "https://res.cloudinary.com/demo/image/upload/portfolio.jpg", position: 1)
    user.likes.create!(artist_profile: artist_profile)

    sign_in user
    get user_path

    assert_response :success
    assert_select "a.like-tile[href='#{artist_path(artist_profile)}']", count: 1 do
      assert_select "img.like-tile-image", count: 1
      assert_select ".like-tile-name", text: "Ink Master", count: 1
    end
  end
end
