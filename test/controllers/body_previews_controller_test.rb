require "test_helper"

class BodyPreviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "bodypreview@example.com",
      password: "password123",
      username: "bodypreviewer",
      birthdate: 20.years.ago
    )
    sign_in @user
  end

  test "multipart create uploads both design and body photo and enqueues the job" do
    design_file = fixture_file_upload("reference_snake.png", "image/png")
    body_file = fixture_file_upload("reference_snake.png", "image/png")

    uploads = [
      { "secure_url" => "https://res.cloudinary.com/demo/image/upload/design.png", "public_id" => "design123" },
      { "secure_url" => "https://res.cloudinary.com/demo/image/upload/body.png", "public_id" => "body123" }
    ]

    stub_singleton_method(Cloudinary::Uploader, :upload, ->(*) { uploads.shift }) do
      assert_enqueued_with(job: BodyPreviewJob) do
        post body_previews_path, params: {
          design_image: design_file,
          body_photo_upload: body_file
        }, as: :multipart_form
      end
    end

    body_preview = BodyPreview.last
    assert_not_nil body_preview
    assert_equal "https://res.cloudinary.com/demo/image/upload/design.png", body_preview.source_image_url
    assert_equal "design123", body_preview.source_image_public_id
    assert_equal "https://res.cloudinary.com/demo/image/upload/body.png", body_preview.body_image_url
    assert_equal "body123", body_preview.body_image_public_id
  end

  test "reuses an already-generated tattoo design and only uploads the body photo" do
    generation = @user.tattoo_generations.create!(
      prompt: "test prompt",
      status: :completed,
      image_url: "https://res.cloudinary.com/demo/image/upload/generated.png",
      image_public_id: "generated123"
    )
    body_file = fixture_file_upload("reference_snake.png", "image/png")

    stub_singleton_method(Cloudinary::Uploader, :upload, ->(*) {
      { "secure_url" => "https://res.cloudinary.com/demo/image/upload/body.png", "public_id" => "body123" }
    }) do
      post body_previews_path, params: {
        tattoo_generation_id: generation.id,
        body_photo_camera: body_file
      }, as: :multipart_form
    end

    body_preview = BodyPreview.last
    assert_equal generation.image_url, body_preview.source_image_url
    assert_equal generation.id, body_preview.tattoo_generation_id
    assert_equal "https://res.cloudinary.com/demo/image/upload/body.png", body_preview.body_image_url
  end

  test "rejects creation without a body photo" do
    generation = @user.tattoo_generations.create!(
      prompt: "test prompt",
      status: :completed,
      image_url: "https://res.cloudinary.com/demo/image/upload/generated.png",
      image_public_id: "generated123"
    )

    assert_no_difference -> { BodyPreview.count } do
      post body_previews_path, params: {
        tattoo_generation_id: generation.id
      }, as: :multipart_form
    end
  end
end
