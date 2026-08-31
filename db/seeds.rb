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

User.create!(
  email: "client@test.com",
  password: "password",
  username: "tattoolover",
  first_name: "Jordan",
  last_name: "Client",
  birthdate: Date.new(1995, 3, 20)
)

fred_user = User.create!(
  email: "fred@test.local",
  password: "password",
  username: "fred",
  birthdate: Date.new(1990, 5, 12),
  city: "Lausanne"
)

second_client_user = User.create!(
  email: "sam@test.local",
  password: "password",
  username: "samtattoo",
  first_name: "Sam",
  last_name: "Rivera",
  birthdate: Date.new(1992, 8, 3)
)

puts "Creating artist profile with schedule..."
artist_profile = ArtistProfile.create!(
  user: artist_user,
  display_name: "InkMaster Studio",
  bio: "Tattoo artist specialized in blackwork and dotwork.",
  styles: "Blackwork, Dotwork, Geometric",
  professional_status: "professional",
  avatar_url: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850482/kitattoo/seeds/h6ddqahql8mtlzcjayz7.jpg",
  avatar_public_id: "kitattoo/seeds/h6ddqahql8mtlzcjayz7",
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
puts "Creating InkMaster portfolio..."
artist_profile.portfolio_items.create!(image_url: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850477/kitattoo/seeds/onnmpkydyfbga1dbq6j9.jpg")
artist_profile.portfolio_items.create!(image_url: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850479/kitattoo/seeds/dnwxvf57p3vkiub5ojl1.jpg")
artist_profile.portfolio_items.create!(image_url: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850480/kitattoo/seeds/weruhjctawmi5ahajkqa.jpg")

artist_profile.portfolio_items.create!(image_url: "https://res.cloudinary.com/efbi2pls/image/upload/v1787852014/kitattoo/seeds/uqb7amnjx8cuk0ukblaz.jpg")

artist_profile.portfolio_items.create!(image_url: "https://res.cloudinary.com/efbi2pls/image/upload/v1787854800/kitattoo/seeds/o00r1jl9zfhsobyltqhe.jpg")
artist_profile.portfolio_items.create!(image_url: "https://res.cloudinary.com/efbi2pls/image/upload/v1787854801/kitattoo/seeds/fxaxgssou3rglulk5thc.jpg")
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

puts "Creating confirmed bookings..."

[
  { client: fred_user, starts_at: 5.days.from_now.change(hour: 11),
    duration: 90, description: "Small blackwork piece on the forearm." },
  { client: second_client_user, starts_at: 12.days.from_now.change(hour: 14),
    duration: 45, description: "Fine line geometric design on the wrist." }
].each do |data|
  Conversation.create!(client: data[:client], artist_profile: artist_profile)

  booking_availability = artist_profile.availabilities.create!(
    address: address,
    starts_at: data[:starts_at],
    ends_at: data[:starts_at] + data[:duration].minutes,
    state: :booked
  )

  booking_availability.build_booking(
    client: data[:client],
    description: data[:description],
    duration: data[:duration],
    status: :confirmed
  ).save!
end

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

images = {
  "inkline" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850063/kitattoo/seeds/a3wbs87is2y3djbqv0do.jpg",
    avatar_id: "kitattoo/seeds/a3wbs87is2y3djbqv0do",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850059/kitattoo/seeds/vcnda5tgyks9a6yhyn6n.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850060/kitattoo/seeds/vev5yl5xn6ndmdul8q1c.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852012/kitattoo/seeds/v9erib4hi4zisvkzpjn3.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850062/kitattoo/seeds/uvkzegzxavrwh0ynq60m.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854797/kitattoo/seeds/f2k8esmdgrmvkdpf6isb.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854798/kitattoo/seeds/h60o0io2lmqxbxkvmcje.jpg"
    ]
  },
  "noiretgris" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850087/kitattoo/seeds/rndvmmyst2ggkkypts39.jpg",
    avatar_id: "kitattoo/seeds/rndvmmyst2ggkkypts39",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852026/kitattoo/seeds/a6cmyl3tz03c1lu5bgip.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852028/kitattoo/seeds/bt2q0xtoiqlcm5d6agqg.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852029/kitattoo/seeds/gc55jel5xqa3gdvfhm0a.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850082/kitattoo/seeds/mjnatmdscxqpyy7pmziu.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850084/kitattoo/seeds/h10u3myfiauy1513gzxk.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850086/kitattoo/seeds/i9ivoijrrwqbpdhmqlk4.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854811/kitattoo/seeds/grpv1pdn4mkcfffe93pq.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854813/kitattoo/seeds/sn5e1lbyb68qcjkd9rnd.jpg"
    ]
  },
  "sionink" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850093/kitattoo/seeds/ylpyl9l8qz963utkvttd.jpg",
    avatar_id: "kitattoo/seeds/ylpyl9l8qz963utkvttd",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850089/kitattoo/seeds/xsilkgls6flbmilma5bi.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850090/kitattoo/seeds/cmfzrcedrfhlrcvtn0cy.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852031/kitattoo/seeds/lku17ayrvbmgtlcgnpdb.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850092/kitattoo/seeds/l7llcd0h5o2piv6to5gg.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854814/kitattoo/seeds/tnlj5mg6suhemh9mlk3k.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854815/kitattoo/seeds/dxjzjsrxeehifcwa3hy9.jpg"
    ]
  },
  "kaiirezumi" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850070/kitattoo/seeds/hkmfolr3q5ohcln4hvou.jpg",
    avatar_id: "kitattoo/seeds/hkmfolr3q5ohcln4hvou",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852015/kitattoo/seeds/rs3qezjgnzhjip5lolft.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852017/kitattoo/seeds/xuueegmnlev2dkrry5cp.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852018/kitattoo/seeds/jldtl1f7e1mhf5td17v0.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850066/kitattoo/seeds/ohysfavauaefhsetpxo7.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850067/kitattoo/seeds/nx9swggppjwwbnx4yqje.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850068/kitattoo/seeds/gu1mnqdukpfldi4elvvb.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854803/kitattoo/seeds/n6sogsncwgo6qae76j7h.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854804/kitattoo/seeds/u0h3eq5ekbilqsuudvue.jpg"
    ]
  },
  "mnemosyne" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850081/kitattoo/seeds/sov6pnmfzboifzjtftyf.jpg",
    avatar_id: "kitattoo/seeds/sov6pnmfzboifzjtftyf",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850077/kitattoo/seeds/fpg3opkvyyacbxe0tgh1.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850078/kitattoo/seeds/tswadvdulicbafbyjo4k.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852025/kitattoo/seeds/lubjatowos6kizqshg3z.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850080/kitattoo/seeds/zkiqvld3in8kevw9c32a.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854808/kitattoo/seeds/xcft158bnuf8ncx67ei1.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854810/kitattoo/seeds/dxqi4lm3ggqrjtjpsxun.jpg"
    ]
  },
  "brouillon" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850046/kitattoo/seeds/sckzhq9lczr3qj4v91pi.jpg",
    avatar_id: "kitattoo/seeds/sckzhq9lczr3qj4v91pi",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850041/kitattoo/seeds/cgo81a4ul02i764bbcmo.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850043/kitattoo/seeds/yboudrwz4aswrgydidh4.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852008/kitattoo/seeds/rvsu7vchv8dnry0ic5oo.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850044/kitattoo/seeds/sxyhcbolssjyuolbnld5.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854788/kitattoo/seeds/bopylm4udcpajehssclz.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854789/kitattoo/seeds/acaje1whv3jc6ujdum3o.jpg"
    ]
  },
  "aiguillefine" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850028/kitattoo/seeds/zjjh5mmaau6iwslpxizj.jpg",
    avatar_id: "kitattoo/seeds/zjjh5mmaau6iwslpxizj",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850023/kitattoo/seeds/jttog9buzqcbjy8pyo8e.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850024/kitattoo/seeds/indvtni8rutmpxsz29qg.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852000/kitattoo/seeds/tb1vzw98ggelgbaaowbw.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850026/kitattoo/seeds/gtemlfqjnp5owpog25rm.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854779/kitattoo/seeds/wx1fqwksc8j4xgwv84ei.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854781/kitattoo/seeds/wlbrjw9f7gjykgoc7zfz.jpg"
    ]
  },
  "boldlines" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850040/kitattoo/seeds/nl3d9h2e7mmzb8lefuq2.jpg",
    avatar_id: "kitattoo/seeds/nl3d9h2e7mmzb8lefuq2",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850035/kitattoo/seeds/ncaaqjod98pqmt521nyn.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850037/kitattoo/seeds/pde8owf30ngjx8bdp2wb.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852007/kitattoo/seeds/uq4t5uz1b3pl5npltl12.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850039/kitattoo/seeds/djoaif1fgiugzla7sf1x.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854785/kitattoo/seeds/y9ngzyo2rrlbzpsqldkg.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854787/kitattoo/seeds/r2ntrcpiatqoanldvafr.jpg"
    ]
  },
  "atelier9" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850034/kitattoo/seeds/hrsfoyilqzdq5fcs94sz.jpg",
    avatar_id: "kitattoo/seeds/hrsfoyilqzdq5fcs94sz",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852002/kitattoo/seeds/xebkeofffidixvqtqz0g.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852003/kitattoo/seeds/alypfgg9dgtg6syvjpgh.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852005/kitattoo/seeds/mbghm6v2bpjo3r9r315g.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850029/kitattoo/seeds/mc3r4upidgq3zu2evtsx.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850031/kitattoo/seeds/hyakwbp2vawiv4bnaxpt.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850032/kitattoo/seeds/btoiqyi0ehu21rhzphmq.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854782/kitattoo/seeds/ksgcl7nqpqdgi7ru5sqz.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854784/kitattoo/seeds/vep8m0wacwpkrerrdxpc.jpg"
    ]
  },
  "encrenoire" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850058/kitattoo/seeds/urothulapatzvogsfak7.jpg",
    avatar_id: "kitattoo/seeds/urothulapatzvogsfak7",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850053/kitattoo/seeds/vsotmu0jkxrhhpggy5f0.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850055/kitattoo/seeds/ner5dizvu3kwkjo74i3u.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852011/kitattoo/seeds/ynt4in3ytpvvjrxzsp01.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850056/kitattoo/seeds/sfmjpj05taxfjh3b3lhp.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854794/kitattoo/seeds/fgke5aia2jknwnah5ak5.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854795/kitattoo/seeds/cetasirpwngp39votzyg.jpg"
    ]
  },
  "maisonsumi" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850075/kitattoo/seeds/r2vjopnnbhoa4i1itan9.jpg",
    avatar_id: "kitattoo/seeds/r2vjopnnbhoa4i1itan9",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852020/kitattoo/seeds/jebazebfpdlavx9f8eeo.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852022/kitattoo/seeds/nkk1lvwseq6cztrn3vv6.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852023/kitattoo/seeds/dnbokmxqf3rknirir0cr.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850071/kitattoo/seeds/au2vaylhnvxlcydvurzr.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850073/kitattoo/seeds/jrowllv91cwikluflhwj.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850074/kitattoo/seeds/yy1ccgt4vjuhqqjfiosd.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854805/kitattoo/seeds/po0e41sxtyuhl3tif8dz.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854807/kitattoo/seeds/cezw7d6kqjjpkklndkus.jpg"
    ]
  },
  "encrefraiche" => {
    avatar: "https://res.cloudinary.com/efbi2pls/image/upload/v1787850052/kitattoo/seeds/ylaesmvmvpvgpumcxano.jpg",
    avatar_id: "kitattoo/seeds/ylaesmvmvpvgpumcxano",
    photos: [
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850047/kitattoo/seeds/p87mupf2yrjxqwhmcdsr.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850049/kitattoo/seeds/ap9tvbuslgt8cvten0hv.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787852009/kitattoo/seeds/hlp8xml5cjp8ncntbxxm.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787850050/kitattoo/seeds/vblmxjubausbvdfrfizf.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854791/kitattoo/seeds/ctmotseru5uzejdncyto.jpg",
      "https://res.cloudinary.com/efbi2pls/image/upload/v1787854792/kitattoo/seeds/snrjxrzfngd1cs50qth8.jpg"
    ]
  }
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
    avatar_url: images[data[:username]][:avatar],
    avatar_public_id: images[data[:username]][:avatar_id],
    pricing_grid: pricings[data[:username]].map { |name, price| { "prestation" => name, "prix" => price } },
    published: data[:published]
  )

  images[data[:username]][:photos].each do |url|
    profile.portfolio_items.create!(image_url: url)
  end

  profile.addresses.create!(
    label: nil,
    street: data[:street],
    zipcode: data[:zipcode],
    city: data[:city]
  )
end

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
