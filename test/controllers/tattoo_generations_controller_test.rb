require "test_helper"

class TattooGenerationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "creator@example.com",
      password: "password123",
      username: "creator",
      birthdate: 20.years.ago
    )
    sign_in @user
  end

  test "multipart create uploads the reference image, persists its URL, and enqueues the job with it" do
    file = fixture_file_upload("reference_snake.png", "image/png")

    uploaded_asset = {
      "secure_url" => "https://res.cloudinary.com/demo/image/upload/uploaded_ref.png",
      "public_id" => "uploaded_ref"
    }

    captured_path = nil
    captured_path_existed = nil
    stub_singleton_method(Cloudinary::Uploader, :upload, ->(path) {
      captured_path = path
      captured_path_existed = File.exist?(path)
      uploaded_asset
    }) do
      assert_enqueued_with(job: TattooGenerationJob) do
        post tattoo_generations_path, params: {
          idea: "A two-headed snake wrapped around an ornamental dagger, framed by three peonies.",
          reference_images: [ file ],
          reference_use_for: [ "composition" ]
        }, as: :multipart_form
      end
    end

    assert_not_nil captured_path, "expected Cloudinary::Uploader.upload to receive a real tempfile path"
    assert captured_path_existed, "expected the path passed to Cloudinary to point at an actual uploaded tempfile"

    generation = TattooGeneration.last
    assert_not_nil generation, "expected a TattooGeneration to have been created"

    assert_equal [ "https://res.cloudinary.com/demo/image/upload/uploaded_ref.png" ], generation.reference_image_urls
    assert_equal [ "uploaded_ref" ], generation.reference_image_public_ids
    assert_not_empty generation.reference_image_urls

    assert_includes generation.prompt, "[REFERENCE 1 GUIDANCE]"
    assert_includes generation.prompt, "spatial arrangement, pose, orientation"

    enqueued = enqueued_jobs.find { |j| j["job_class"] == "TattooGenerationJob" }
    assert_equal [ generation.id ], enqueued["arguments"]
  end

  test "create without any reference image persists empty reference arrays" do
    assert_enqueued_with(job: TattooGenerationJob) do
      post tattoo_generations_path, params: {
        idea: "A two-headed snake wrapped around an ornamental dagger, framed by three peonies."
      }, as: :multipart_form
    end

    generation = TattooGeneration.last
    assert_empty generation.reference_image_urls
    assert_empty generation.reference_image_public_ids
    assert_not_includes generation.prompt, "[REFERENCE"
  end

  test "create with a reference image and no idea is valid" do
    file = fixture_file_upload("reference_snake.png", "image/png")

    stub_singleton_method(Cloudinary::Uploader, :upload, ->(*) {
      { "secure_url" => "https://res.cloudinary.com/demo/image/upload/uploaded_ref.png", "public_id" => "uploaded_ref" }
    }) do
      post tattoo_generations_path, params: { reference_images: [ file ] }, as: :multipart_form
    end

    generation = TattooGeneration.last
    assert_not_nil generation
    assert_includes generation.prompt, "No written concept was provided"
  end

  test "create without idea and without reference image is rejected" do
    assert_no_difference -> { TattooGeneration.count } do
      post tattoo_generations_path, params: {}, as: :multipart_form
    end
  end
end
