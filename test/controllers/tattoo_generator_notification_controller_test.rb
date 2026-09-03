require "test_helper"

class TattooGeneratorNotificationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "notif_ctrl@example.com", password: "password123", username: "notif_ctrl", birthdate: 20.years.ago)
    @other_user = User.create!(email: "notif_ctrl_other@example.com", password: "password123", username: "notif_ctrl_other", birthdate: 20.years.ago)
  end

  test "mark_viewed on a tattoo generation requires authentication" do
    generation = @user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")

    patch mark_viewed_tattoo_generation_path(generation)

    assert_redirected_to new_user_session_path
    assert_nil generation.reload.viewed_at
  end

  test "mark_viewed on a tattoo generation is scoped to current_user" do
    generation = @other_user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")
    sign_in @user

    patch mark_viewed_tattoo_generation_path(generation)

    assert_response :not_found
    assert_nil generation.reload.viewed_at
  end

  test "mark_viewed on a tattoo generation marks it viewed for its owner" do
    generation = @user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")
    sign_in @user

    patch mark_viewed_tattoo_generation_path(generation)

    assert_response :no_content
    assert generation.reload.viewed_at.present?
  end

  test "mark_viewed on a body preview requires authentication and is scoped to current_user" do
    preview = @other_user.body_previews.create!(
      source_image_url: "https://x/design.png", body_image_url: "https://x/body.png",
      status: :completed, preview_image_url: "https://x/result.png", preview_image_public_id: "result"
    )

    patch mark_viewed_body_preview_path(preview)
    assert_redirected_to new_user_session_path

    sign_in @user
    patch mark_viewed_body_preview_path(preview)
    assert_response :not_found
  end

  test "mark_viewed on a body preview marks it viewed for its owner" do
    preview = @user.body_previews.create!(
      source_image_url: "https://x/design.png", body_image_url: "https://x/body.png",
      status: :completed, preview_image_url: "https://x/result.png", preview_image_public_id: "result"
    )
    sign_in @user

    patch mark_viewed_body_preview_path(preview)

    assert_response :no_content
    assert preview.reload.viewed_at.present?
  end

  test "the badge appears elsewhere in the app for a signed-in user with an unnotified result, and never for a visitor" do
    @user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")

    get artists_path
    assert_select ".botappbar-dot--accent", count: 0

    sign_in @user
    get artists_path
    assert_select "#tattoo-generator-notification-badge .botappbar-dot--accent", count: 1
  end
end
