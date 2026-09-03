require "test_helper"

class TattooGeneratorPageTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "new page renders for a user with no prior generations or previews" do
    user = User.create!(email: "page1@example.com", password: "password123", username: "page1", birthdate: 20.years.ago)
    sign_in user

    get new_tattoo_generation_path
    assert_response :success
    assert_select ".tattoo-generator-card[data-controller~='collapsible-card']", count: 2
    assert_select "button[data-collapsible-card-target='button'][aria-expanded='false']", count: 2
    assert_select "[data-collapsible-card-target='content'][hidden]", count: 2
    assert_select "#create-tattoo-card-content[role='region'][aria-labelledby='create-tattoo-card-title']", count: 1
    assert_select "#body-preview-card-content[role='region'][aria-labelledby='body-preview-card-title']", count: 1
    assert_select ".tattoo-generator-card[data-body-preview-source-target='bodyPreviewCard'][data-action='body-preview-source:open-card->collapsible-card#open']", count: 1 do
      assert_select "#body-preview-card-content", count: 1
    end
  end

  test "new page restores the user's last generation and body preview across every status" do
    user = User.create!(email: "page2@example.com", password: "password123", username: "page2", birthdate: 20.years.ago)
    sign_in user

    [ :pending, :completed, :failed ].each do |status|
      generation = user.tattoo_generations.create!(
        prompt: "prompt for #{status}",
        status: status,
        image_url: (status == :completed ? "https://res.cloudinary.com/demo/image/upload/y.png" : nil),
        image_public_id: (status == :completed ? "y" : nil)
      )
      body_preview = user.body_previews.create!(
        source_image_url: "https://res.cloudinary.com/demo/image/upload/design.png",
        body_image_url: "https://res.cloudinary.com/demo/image/upload/body.png",
        status: status,
        preview_image_url: (status == :completed ? "https://res.cloudinary.com/demo/result.png" : nil),
        preview_image_public_id: (status == :completed ? "result123" : nil)
      )

      get new_tattoo_generation_path
      assert_response :success
      assert_select "#tattoo_generation_result"
      assert_select "#body_preview_result"
    end
  end
end
