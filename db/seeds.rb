# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

artist_user = User.find_or_create_by!(email: "artist@kitatoo.test") do |u|
  u.username = "inkmaster"
  u.password = "password123"
  u.first_name = "Alex"
  u.last_name = "Martin"
  u.birthdate = 30.years.ago
  u.city = "Paris"
end

client_user = User.find_or_create_by!(email: "client@kitatoo.test") do |u|
  u.username = "client_jane"
  u.password = "password123"
  u.first_name = "Jane"
  u.last_name = "Doe"
  u.birthdate = 25.years.ago
  u.city = "Paris"
end

artist_profile = ArtistProfile.find_or_create_by!(user: artist_user) do |ap|
  ap.display_name = "Alex Ink"
  ap.bio = "Tattoo artist specialized in fine line and blackwork."
  ap.styles = "Fine line, Blackwork"
  ap.professional_status = "Professional"
  ap.published = true
end

conversation = Conversation.find_or_create_by!(client: client_user, artist_profile: artist_profile)

if conversation.messages.none?
  conversation.messages.create!(user: client_user, body: "Hi! I'd love a fine line tattoo, do you have availability soon?")
  conversation.messages.create!(user: artist_user, body: "Hello Jane! Let me check my schedule and get back to you.")
  conversation.messages.create!(user: client_user, body: "Great, thank you!")
end

puts "Done. Log in as client@kitatoo.test or artist@kitatoo.test with password 'password123'."
puts "Conversation to test: /conversations/#{conversation.id}"
