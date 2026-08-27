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
  published: true,
  pricing_grid: [
    { "prestation" => "Small piece (< 10cm)", "prix" => 80 },
    { "prestation" => "Medium piece", "prix" => 200 },
    { "prestation" => "Half sleeve", "prix" => 500 },
    { "prestation" => "Full back", "prix" => 1500 }
  ],
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

puts "Creating conversation and booking..."
conversation = Conversation.create!(
  client: client_user,
  artist_profile: artist_profile
)

Message.create!(
  conversation: conversation,
  user: client_user,
  body: "Hi! I'd love to book a session for a small piece on my forearm."
)

availability = Availability.first
Booking.create!(
  availability: availability,
  client: client_user,
  status: :selected
)

puts "Done!"

puts "Creating artists..."
artists = [
  { username: "inkline",      status: "Studio owner",    display_name: "Ink Line Studio",  styles: "Blackwork, Fine Line",    city: "Lausanne",  street: "Rue de Bourg 12",        zipcode: "1003",  published: true },
  { username: "noiretgris",   status: "Independent",     display_name: "Noir et Gris",     styles: "Realism, Blackwork",      city: "Geneve",    street: "Rue du Rhone 45",        zipcode: "1204",  published: true },
  { username: "sionink",      status: "Studio resident", display_name: "Sion Ink",         styles: "Traditional, Japanese",   city: "Sion",      street: "Avenue de la Gare 8",    zipcode: "1950",  published: true },
  { username: "kaiirezumi",   status: "Guest artist",    display_name: "Kai Irezumi",      styles: "Japanese, Blackwork",     city: "Geneve",    street: "Boulevard Carl-Vogt 3",  zipcode: "1205",  published: true },
  { username: "mnemosyne",    status: "Independent",     display_name: "Mnemosyne Tattoo", styles: "Surrealism, Fine Line",   city: "Neuchatel", street: "Rue du Seyon 5",         zipcode: "2000",  published: true },
  { username: "brouillon",    status: "Apprentice",      display_name: "Studio Brouillon", styles: "Watercolor",              city: "Martigny",  street: "Rue des Alpes 2",        zipcode: "1920",  published: false },
  { username: "aiguillefine", status: "Studio resident", display_name: "Aiguille Fine",    styles: "Fine Line, Watercolor",   city: "Lyon",      street: "Rue de la Republique 24", zipcode: "69002", published: true },
  { username: "boldlines",    status: "Independent",     display_name: "Bold Lines",       styles: "Neo-Traditional",         city: "Marseille", street: "Cours Julien 17",        zipcode: "13006", published: true },
  { username: "atelier9",     status: "Studio owner",    display_name: "Atelier Neuf",     styles: "Photorealism, Blackwork", city: "Bordeaux",  street: "Rue Sainte-Catherine 88", zipcode: "33000", published: true },
  { username: "encrenoire",   status: "Guest artist",    display_name: "Encre Noire",      styles: "Blackwork, Dotwork",      city: "Lyon",      street: "Rue Paul Bert 41",       zipcode: "69003", published: true },
  { username: "maisonsumi",   status: "Independent",     display_name: "Maison Sumi",      styles: "Japanese, Fine Line",     city: "Lille",     street: "Rue de Bethune 9",       zipcode: "59000", published: true },
  { username: "encrefraiche", status: "Apprentice",      display_name: "Encre Fraiche",    styles: "Traditional, Fine Line",  city: "Nantes",    street: "Rue Crebillon 12",       zipcode: "44000", published: false }
]

bios = {
  "inkline" => "Blackwork and fine line since 2014. I work from a private studio in Lausanne, one client at a time, mostly on large ongoing pieces that take several sessions to finish. I draw everything by hand before we start and we adjust the stencil together until it sits right on your body. I do not tattoo hands, necks or faces on a first appointment. Walk-ins on Saturdays only, everything else is by appointment.",
  "noiretgris" => "Black and grey realism, portraits and animals. I draw everything myself from the reference photos you send me, and we go through the drawing together before the needle touches skin. A portrait usually takes two sessions of four hours. I would rather turn a project down than rush it, so if I say no it is not personal. Consultations happen in the studio, never by message only.",
  "sionink" => "Traditional and Japanese work in the Valais, in the same shop for eleven years. Bold lines, solid colour, designs meant to still read in thirty years. I keep flash sheets at the studio and I am always happier tattooing from them than copying a screenshot. Cover-ups welcome, but come and show me the piece first so I can tell you honestly what is possible.",
  "kaiirezumi" => "Japanese tattooing in the tebori tradition, adapted to the machine. I travel between Geneva, Berlin and Osaka, and booking opens for three weeks at a time when I know my dates. Sleeves and back pieces are built over many sessions, sometimes across a year. I ask for a deposit because a cancelled day cannot be filled when I am only in town for a fortnight.",
  "mnemosyne" => "Surrealist compositions and fine line. I like projects that carry a story, so expect questions before we start drawing, and expect me to send you something different from what you had in mind. Sessions run four hours minimum because this kind of work does not survive being cut into small pieces. I keep two slots a month for people who cannot pay full price.",
  "brouillon" => "Apprentice in Martigny, second year. Watercolour and small colour pieces at reduced rates while I build my portfolio, always with my mentor in the room. I will tell you plainly when a project is beyond what I can do yet and pass you to someone in the shop. Everything I tattoo, I have drawn at least three times before you sit down.",
  "aiguillefine" => "Fine line and watercolour in Lyon. Delicate work, thin needles, a lot of white space left on purpose. I do not do cover-ups and I do not tattoo over scars, but I am happy to point you to two people in town who do it well. Small pieces are often done in a single hour. If you have never been tattooed, say so and we will take the time you need.",
  "boldlines" => "Neo-traditional, heavy on colour and outline. Roses, panthers, ships, the classics done properly. I keep a flash book at the shop and I would rather tattoo from it than copy something you found online, because I know how those designs age. Come with an idea and a body part, not with a picture. Colour needs care in the sun, and I will tell you how.",
  "atelier9" => "Photorealism and blackwork in Bordeaux. Large formats, chest and back pieces built over several sessions across a few months. I only take projects I know I can finish properly, which means I turn down more work than I accept. Bring your reference photos in the highest resolution you have. Healing matters as much as the tattoo, so I follow up after every session.",
  "encrenoire" => "Blackwork and dotwork, geometric patterns and ornamental work that follows the lines of the body. Guest spots across France, currently based in Lyon until spring. Dotwork takes longer than people expect and cannot be rushed without losing the texture. I work in silence mostly, but tell me if you would rather talk, it makes the hours pass.",
  "maisonsumi" => "Japanese motifs drawn with a fine line approach. Koi, waves, peonies, at a smaller scale than traditional irezumi and with a lighter hand. Consultations are free and take about an hour, because getting the flow right on the body matters more than the drawing itself. I work by appointment only, Tuesday to Saturday, and I answer messages once a day in the evening.",
  "encrefraiche" => "Learning traditional and fine line in Nantes, first year of apprenticeship. Small pieces only for now, always with my mentor watching. Prices reflect that I am still training, and I would rather you know that upfront than find out afterwards. I redraw every design several times before the appointment. If your idea is too ambitious for me, I will say so.",
}

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
    bio: bios[data[:username]],
    professional_status: data[:status],
    pricing_grid: pricings[data[:username]].map { |name, price| { "prestation" => name, "prix" => price } },
    published: data[:published]
  )

  profile.addresses.create!(
    label: nil,
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

puts "Creating tags from styles..."
ArtistProfile.all.each do |profile|
  next if profile.styles.blank?

  profile.styles.split(",").map { |name| name.strip }.each do |name|
    tag = Tag.find_or_create_by_name!(name)
    profile.tags << tag unless profile.tags.include?(tag)
  end
end
puts "Tags: #{Tag.count}, links: #{ArtistProfileTag.count}"
