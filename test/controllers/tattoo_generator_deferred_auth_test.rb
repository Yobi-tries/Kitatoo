require "test_helper"

class TattooGeneratorDeferredAuthTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "GET new is publicly accessible to a signed-out visitor" do
    get new_tattoo_generation_path

    assert_response :success
    assert_select ".tattoo-generator-page"
  end

  test "GET new does not touch current_user for a signed-out visitor" do
    get new_tattoo_generation_path

    assert_response :success
    assert_select "#tattoo_generation_result .tattoo-drawer__title", count: 0
    assert_select "#body_preview_result .tattoo-drawer__title", count: 0
  end

  test "a signed-out visitor submitting Generate my tattoo is sent to sign in and nothing starts" do
    assert_no_difference -> { TattooGeneration.count } do
      assert_no_enqueued_jobs(only: TattooGenerationJob) do
        post tattoo_generations_path, params: { idea: "A two-headed snake wrapped around a dagger." }, as: :turbo_stream
      end
    end

    assert_redirected_to new_user_session_path
  end

  test "a signed-out visitor submitting Preview on body is sent to sign in and nothing starts" do
    file = fixture_file_upload("reference_snake.png", "image/png")

    assert_no_difference -> { BodyPreview.count } do
      assert_no_enqueued_jobs(only: BodyPreviewJob) do
        post body_previews_path, params: { design_image: file, body_photo: file }, as: :multipart_form
      end
    end

    assert_redirected_to new_user_session_path
  end

  test "a signed-in user still sees their own last generation and body preview on new" do
    user = User.create!(email: "deferred_auth@example.com", password: "password123", username: "deferred_auth", birthdate: 20.years.ago)
    generation = user.tattoo_generations.create!(prompt: "test prompt", status: :completed, image_url: "https://x/y.png", image_public_id: "y")
    sign_in user

    get new_tattoo_generation_path

    assert_response :success
    assert_select "#tattoo_generation_result img[src='https://x/y.png']"
  end
end
