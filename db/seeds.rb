puts "Cleaning database..."
Booking.destroy_all
Availability.destroy_all
Address.destroy_all
PortfolioItem.destroy_all
Conversation.destroy_all
Message.destroy_all
TattooGeneration.destroy_all
ArtistProfile.destroy_all
User.destroy_all

puts "Creating users..."
artist_user = User.create!(
  email: "artist@test.com",
  password: "password",
  username: "inkmaster",
  first_name: "Alex",
  last_name: "Tattoo",
  birthdate: Date.new(1990, 5, 15)
)

client_user = User.create!(
  email: "client@test.com",
  password: "password",
  username: "tattoolover",
  first_name: "Jordan",
  last_name: "Client",
  birthdate: Date.new(1995, 3, 20)
)

puts "Creating artist profile with schedule..."
artist_profile = ArtistProfile.create!(
  user: artist_user,
  display_name: "InkMaster Studio",
  bio: "Tattoo artist specialized in blackwork and dotwork.",
  styles: "Blackwork, Dotwork, Geometric",
  professional_status: "professional",
  pricing_grid: "Small piece: 80€\nMedium piece: 200€\nHalf sleeve: 500€",
  schedule: {
    "slot_duration" => 45,
    "period_start" => Date.today.to_s,
    "period_end" => (Date.today + 6.months).to_s,
    "days" => {
      "monday" => { "start" => "09:00", "end" => "17:00" },
      "tuesday" => { "start" => "10:00", "end" => "18:00" },
      "wednesday" => nil,
      "thursday" => { "start" => "09:00", "end" => "17:00" },
      "friday" => { "start" => "09:00", "end" => "16:00" },
      "saturday" => { "start" => "10:00", "end" => "14:00" },
      "sunday" => nil
    },
    "days_off" => ["2026-12-24", "2026-12-25", "2026-12-31"]
  },
  published: true
)

puts "Creating addresses..."
Address.create!(
  artist_profile: artist_profile,
  label: "Main studio",
  street: "42 Rue de la Roquette",
  zipcode: "75011",
  city: "Paris"
)

puts "Done! Artist: artist@test.com / password | Client: client@test.com / password"
