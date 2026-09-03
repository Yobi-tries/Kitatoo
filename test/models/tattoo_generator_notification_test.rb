require "test_helper"

class TattooGeneratorNotificationTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "notif@example.com", password: "password123", username: "notif_user", birthdate: 20.years.ago)
  end

  test "a completed tattoo generation with a result is unnotified until viewed" do
    generation = @user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")

    assert @user.unnotified_tattoo_generator_results?
    assert_includes TattooGeneration.unnotified, generation
  end

  test "pending, failed, or resultless generations never count as unnotified" do
    @user.tattoo_generations.create!(prompt: "p", status: :pending)
    @user.tattoo_generations.create!(prompt: "p", status: :failed)
    @user.tattoo_generations.create!(prompt: "p", status: :completed) # completed but no image_url/public_id

    assert_not @user.unnotified_tattoo_generator_results?
  end

  test "a completed body preview with a result is unnotified until viewed" do
    preview = @user.body_previews.create!(
      source_image_url: "https://x/design.png", body_image_url: "https://x/body.png",
      status: :completed, preview_image_url: "https://x/result.png", preview_image_public_id: "result"
    )

    assert @user.unnotified_tattoo_generator_results?
    assert_includes BodyPreview.unnotified, preview
  end

  test "mark_viewed! clears the badge only once the last unviewed result is viewed" do
    generation = @user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")
    preview = @user.body_previews.create!(
      source_image_url: "https://x/design.png", body_image_url: "https://x/body.png",
      status: :completed, preview_image_url: "https://x/result.png", preview_image_public_id: "result"
    )

    assert @user.unnotified_tattoo_generator_results?

    generation.mark_viewed!
    assert @user.unnotified_tattoo_generator_results?, "the still-unviewed body preview should keep the badge on"

    preview.mark_viewed!
    assert_not @user.unnotified_tattoo_generator_results?
  end

  test "mark_viewed! is idempotent and does not overwrite an existing viewed_at" do
    generation = @user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")
    generation.mark_viewed!
    first_viewed_at = generation.reload.viewed_at

    travel 1.hour do
      generation.mark_viewed!
    end

    assert_equal first_viewed_at, generation.reload.viewed_at
  end

  test "results belonging to another user do not affect this user's badge" do
    other_user = User.create!(email: "other@example.com", password: "password123", username: "other_user", birthdate: 20.years.ago)
    other_user.tattoo_generations.create!(prompt: "p", status: :completed, image_url: "https://x/y.png", image_public_id: "y")

    assert_not @user.unnotified_tattoo_generator_results?
  end
end
