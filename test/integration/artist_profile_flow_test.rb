require "test_helper"

class ArtistProfileFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "flow@test.local", password: "password",
                         username: "flowuser", birthdate: Date.new(1990, 1, 1))
  end

  test "visiteur non connecte est renvoye vers la connexion" do
    get new_artist_profile_path
    assert_redirected_to new_user_session_path
  end

  test "utilisateur connecte voit le formulaire" do
    sign_in @user
    get new_artist_profile_path
    assert_response :success
    assert_select "form[action=?]", artist_profile_path
    assert_select "input[name=?]", "artist_profile[display_name]"
  end

  test "creation valide : profil cree, user impose, published false, redirection edit" do
    sign_in @user
    assert_difference "ArtistProfile.count", 1 do
      post artist_profile_path, params: { artist_profile: { display_name: "Encre Noire" } }
    end
    assert_redirected_to edit_artist_profile_path
    p = ArtistProfile.last
    assert_equal @user.id, p.user_id
    assert_equal false, p.published
    assert_equal "Encre Noire", p.display_name
  end

  test "creation invalide : 422, aucun profil cree" do
    sign_in @user
    assert_no_difference "ArtistProfile.count" do
      post artist_profile_path, params: { artist_profile: { display_name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "user_id envoye par le formulaire est ignore" do
    other = User.create!(email: "other@test.local", password: "password",
                         username: "other", birthdate: Date.new(1991, 2, 2))
    sign_in @user
    post artist_profile_path, params: { artist_profile: { display_name: "Hack", user_id: other.id } }
    assert_equal @user.id, ArtistProfile.last.user_id
  end

  test "garde-fou : profil deja existant renvoie vers edit sans creer" do
    sign_in @user
    @user.create_artist_profile!(display_name: "Deja la")

    get new_artist_profile_path
    assert_redirected_to edit_artist_profile_path

    assert_no_difference "ArtistProfile.count" do
      post artist_profile_path, params: { artist_profile: { display_name: "Second" } }
    end
    assert_redirected_to edit_artist_profile_path
  end
end
