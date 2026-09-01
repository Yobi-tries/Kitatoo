require "test_helper"

class BodyPreviewJobTest < ActiveJob::TestCase
  setup do
    @user = User.create!(
      email: "bodypreviewjob@example.com",
      password: "password123",
      username: "bodypreviewjobuser",
      birthdate: 20.years.ago
    )
  end

  test "calls RubyLLM.paint with [body photo, tattoo design] and input_fidelity high" do
    body_preview = @user.body_previews.create!(
      source_image_url: "https://res.cloudinary.com/demo/image/upload/design.png",
      body_image_url: "https://res.cloudinary.com/demo/image/upload/body.png"
    )

    fake_image = Struct.new(:to_blob, :mime_type).new("binarydata", "image/png")
    captured_with = :not_set
    captured_params = :not_set

    stub_singleton_method(RubyLLM, :paint, ->(prompt, model:, with:, params:) {
      captured_with = with
      captured_params = params
      fake_image
    }) do
      stub_singleton_method(Cloudinary::Uploader, :upload, ->(*) {
        { "secure_url" => "https://res.cloudinary.com/demo/result.png", "public_id" => "result123" }
      }) do
        BodyPreviewJob.perform_now(body_preview.id)
      end
    end

    assert_equal [
      "https://res.cloudinary.com/demo/image/upload/body.png",
      "https://res.cloudinary.com/demo/image/upload/design.png"
    ], captured_with
    assert_equal({ input_fidelity: "high" }, captured_params)
    assert body_preview.reload.completed?
  end

  test "marks the record failed (not left pending) when RubyLLM.paint raises a network error" do
    body_preview = @user.body_previews.create!(
      source_image_url: "https://res.cloudinary.com/demo/image/upload/design.png",
      body_image_url: "https://res.cloudinary.com/demo/image/upload/body.png"
    )

    stub_singleton_method(RubyLLM, :paint, ->(*, **) { raise Faraday::ConnectionFailed, "Connection reset by peer" }) do
      BodyPreviewJob.perform_now(body_preview.id)
    end

    assert body_preview.reload.failed?
  end
end
