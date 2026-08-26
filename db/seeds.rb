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
  { username: "inkline", status: "Studio owner",      display_name: "Ink Line Studio",  styles: "Blackwork, Fine Line",    city: "Lausanne",  street: "Rue de Bourg 12",        zipcode: "1003",  published: true },
  { username: "noiretgris", status: "Independent",   display_name: "Noir et Gris",     styles: "Realism, Blackwork",      city: "Geneve",    street: "Rue du Rhone 45",        zipcode: "1204",  published: true },
  { username: "sionink", status: "Studio resident",      display_name: "Sion Ink",         styles: "Traditional, Japanese",   city: "Sion",      street: "Avenue de la Gare 8",    zipcode: "1950",  published: true },
  { username: "kaiirezumi", status: "Guest artist",   display_name: "Kai Irezumi",      styles: "Japanese, Blackwork",     city: "Geneve",    street: "Boulevard Carl-Vogt 3",  zipcode: "1205",  published: true },
  { username: "mnemosyne", status: "Independent",    display_name: "Mnemosyne Tattoo", styles: "Surrealism, Fine Line",   city: "Neuchatel", street: "Rue du Seyon 5",         zipcode: "2000",  published: true },
  { username: "brouillon", status: "Apprentice",    display_name: "Studio Brouillon", styles: "Watercolor",              city: "Martigny",  street: "Rue des Alpes 2",        zipcode: "1920",  published: false },
  { username: "aiguillefine", status: "Studio resident", display_name: "Aiguille Fine",    styles: "Fine Line, Watercolor",   city: "Lyon",      street: "Rue de la Republique 24", zipcode: "69002", published: true },
  { username: "boldlines", status: "Independent",    display_name: "Bold Lines",       styles: "Neo-Traditional",         city: "Marseille", street: "Cours Julien 17",        zipcode: "13006", published: true },
  { username: "atelier9", status: "Studio owner",     display_name: "Atelier Neuf",     styles: "Photorealism, Blackwork", city: "Bordeaux",  street: "Rue Sainte-Catherine 88", zipcode: "33000", published: true },
  { username: "encrenoire", status: "Guest artist",   display_name: "Encre Noire",      styles: "Blackwork, Dotwork",      city: "Lyon",      street: "Rue Paul Bert 41",       zipcode: "69003", published: true },
  { username: "maisonsumi", status: "Independent",   display_name: "Maison Sumi",      styles: "Japanese, Fine Line",     city: "Lille",     street: "Rue de Bethune 9",       zipcode: "59000", published: true },
  { username: "encrefraiche", status: "Apprentice", display_name: "Encre Fraiche",    styles: "Traditional, Fine Line",  city: "Nantes",    street: "Rue Crebillon 12",       zipcode: "44000", published: false }
]

pricings = {
  "inkline"      => [ [ "Flash piece", 150 ], [ "Medium piece", 380 ], [ "Half sleeve", 950 ], [ "Full back", 2400 ] ],
  "noiretgris"   => [ [ "Small realism", 200 ], [ "Portrait", 600 ], [ "Half sleeve", 1400 ] ],
  "sionink"      => [ [ "Flash piece", 120 ], [ "Traditional medium", 300 ], [ "Full sleeve", 1800 ] ],
  "kaiirezumi"   => [ [ "Consultation", 80 ], [ "Irezumi panel", 900 ], [ "Full back", 3200 ] ],
  "mnemosyne"    => [ [ "Fine line small", 110 ], [ "Surrealist piece", 450 ], [ "Half sleeve", 1100 ] ],
  "brouillon"    => [ [ "Flash piece", 60 ], [ "Medium piece", 180 ] ],
  "aiguillefine" => [ [ "Fine line small", 90 ], [ "Watercolor medium", 280 ], [ "Half sleeve", 800 ] ],
  "boldlines"    => [ [ "Flash piece", 130 ], [ "Neo-traditional medium", 350 ], [ "Full sleeve", 1600 ] ],
  "atelier9"     => [ [ "Photorealism small", 250 ], [ "Portrait", 750 ], [ "Full back", 2900 ] ],
  "encrenoire"   => [ [ "Dotwork small", 140 ], [ "Blackwork medium", 400 ], [ "Half sleeve", 1000 ] ],
  "maisonsumi"   => [ [ "Fine line small", 100 ], [ "Japanese panel", 700 ], [ "Full sleeve", 2100 ] ],
  "encrefraiche" => [ [ "Flash piece", 70 ], [ "Traditional medium", 220 ] ]
}

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
    professional_status: data[:status],
    pricing_grid: pricings[data[:username]].map { |name, price| { "prestation" => name, "prix" => price } },
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
