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

puts "Creating artist profile..."
artist_profile = ArtistProfile.create!(
  user: artist_user,
  display_name: "InkMaster Studio",
  bio: "Tattoo artist specialized in blackwork and dotwork.",
  styles: "Blackwork, Dotwork, Geometric",
  professional_status: "professional",
  pricing_grid: [
    { "prestation" => "Small piece (< 10cm)", "prix" => 80 },
    { "prestation" => "Medium piece", "prix" => 200 },
    { "prestation" => "Half sleeve", "prix" => 500 },
    { "prestation" => "Full back", "prix" => 1500 }
  ],
  published: true
)

puts "Creating addresses..."
address = Address.create!(
  artist_profile: artist_profile,
  label: "Main studio",
  street: "42 Rue de la Roquette",
  zipcode: "75011",
  city: "Paris"
)

puts "Creating availabilities..."
3.times do |i|
  Availability.create!(
    artist_profile: artist_profile,
    address: address,
    starts_at: (i + 1).days.from_now.change(hour: 10),
    ends_at: (i + 1).days.from_now.change(hour: 12),
    state: :open
  )
end

puts "Done! Artist: artist@test.com / password | Client: client@test.com / password"

puts "Creating artists..."
artists = [
  { username: "inkline",      display_name: "Ink Line Studio",  styles: "Blackwork, Fine Line",    city: "Lausanne",  street: "Rue de Bourg 12",        zipcode: "1003",  published: true },
  { username: "noiretgris",   display_name: "Noir et Gris",     styles: "Realism, Blackwork",      city: "Geneve",    street: "Rue du Rhone 45",        zipcode: "1204",  published: true },
  { username: "sionink",      display_name: "Sion Ink",         styles: "Traditional, Japanese",   city: "Sion",      street: "Avenue de la Gare 8",    zipcode: "1950",  published: true },
  { username: "kaiirezumi",   display_name: "Kai Irezumi",      styles: "Japanese, Blackwork",     city: "Geneve",    street: "Boulevard Carl-Vogt 3",  zipcode: "1205",  published: true },
  { username: "mnemosyne",    display_name: "Mnemosyne Tattoo", styles: "Surrealism, Fine Line",   city: "Neuchatel", street: "Rue du Seyon 5",         zipcode: "2000",  published: true },
  { username: "brouillon",    display_name: "Studio Brouillon", styles: "Watercolor",              city: "Martigny",  street: "Rue des Alpes 2",        zipcode: "1920",  published: false },
  { username: "aiguillefine", display_name: "Aiguille Fine",    styles: "Fine Line, Watercolor",   city: "Lyon",      street: "Rue de la Republique 24", zipcode: "69002", published: true },
  { username: "boldlines",    display_name: "Bold Lines",       styles: "Neo-Traditional",         city: "Marseille", street: "Cours Julien 17",        zipcode: "13006", published: true },
  { username: "atelier9",     display_name: "Atelier Neuf",     styles: "Photorealism, Blackwork", city: "Bordeaux",  street: "Rue Sainte-Catherine 88", zipcode: "33000", published: true },
  { username: "encrenoire",   display_name: "Encre Noire",      styles: "Blackwork, Dotwork",      city: "Lyon",      street: "Rue Paul Bert 41",       zipcode: "69003", published: true },
  { username: "maisonsumi",   display_name: "Maison Sumi",      styles: "Japanese, Fine Line",     city: "Lille",     street: "Rue de Bethune 9",       zipcode: "59000", published: true },
  { username: "encrefraiche", display_name: "Encre Fraiche",    styles: "Traditional, Fine Line",  city: "Nantes",    street: "Rue Crebillon 12",       zipcode: "44000", published: false }
]

artists.each do |data|
  user = User.create!(
    email: "#{data[:username]}@kitattoo.test",
    password: "password",
    username: data[:username],
    birthdate: Date.new(1988, 1, 1),
    city: data[:city]
  )

  profile = user.create_artist_profile!(
    display_name: data[:display_name],
    styles: data[:styles],
    bio: "#{data[:display_name]} works in #{data[:city]}.",
    professional_status: "Independent",
    published: data[:published]
  )

  profile.addresses.create!(
    label: "Studio",
    street: data[:street],
    zipcode: data[:zipcode],
    city: data[:city]
  )
end

User.create!(
  email: "fred@test.local",
  password: "password",
  username: "fred",
  birthdate: Date.new(1990, 5, 12),
  city: "Lausanne"
)

puts "Total: #{User.count} users, #{ArtistProfile.count} artist profiles, #{Address.count} addresses."
