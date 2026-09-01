require "test_helper"

class TattooGenerationJobTest < ActiveJob::TestCase
  setup do
    @user = User.create!(
      email: "job@example.com",
      password: "password123",
      username: "jobuser",
      birthdate: 20.years.ago
    )
  end

  test "calls RubyLLM.paint with the reference URLs and input_fidelity high when references exist" do
    generation = @user.tattoo_generations.create!(
      prompt: "test prompt",
      reference_image_urls: [ "https://res.cloudinary.com/demo/image/upload/ref1.png" ],
      reference_image_public_ids: [ "ref1" ]
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
        TattooGenerationJob.perform_now(generation.id)
      end
    end

    assert_equal [ "https://res.cloudinary.com/demo/image/upload/ref1.png" ], captured_with
    assert_equal({ input_fidelity: "high" }, captured_params)
    assert generation.reload.completed?
  end

  test "calls RubyLLM.paint with with: nil and no input_fidelity when there are no references" do
    generation = @user.tattoo_generations.create!(prompt: "test prompt")

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
        TattooGenerationJob.perform_now(generation.id)
      end
    end

    assert_nil captured_with
    assert_equal({}, captured_params)
    assert generation.reload.completed?
  end
end
