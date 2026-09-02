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
    "period_start" => Date.current.to_s,
    "period_end" => (Date.current + 6.months).to_s,
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

# Main studio is closed Wednesdays and Sundays — nudge these fixed offsets forward so
# they never silently land on a closed day no matter what "today" happens to be.
next_open_weekday = ->(offset) {
  offset += 1 while [ 0, 3 ].include?(offset.days.from_now.wday) # Sunday, Wednesday
  offset
}
fred_offset = next_open_weekday.call(5)
sam_offset = next_open_weekday.call(12)

[
  { client: fred_user, starts_at: fred_offset.days.from_now.change(hour: 11),
    duration: 90, description: "Small blackwork piece on the forearm." },
  { client: second_client_user, starts_at: sam_offset.days.from_now.change(hour: 11),
    duration: 45, description: "Fine line geometric design on the wrist." }
].each do |data|
  conversation = Conversation.create!(client: data[:client], artist_profile: artist_profile)
  request_time = [ data[:starts_at] - rand(3..8).days, Time.current - rand(1..5).days ].min
  conversation.messages.create!(
    user: data[:client], body: "Hi! I'd love to book a session: #{data[:description]}", created_at: request_time
  )
  reply_time = [ request_time + rand(2..20).hours, Time.current ].min
  conversation.messages.create!(
    user: artist_user, body: "Thanks for reaching out! I'd be happy to take that on, let's lock in a slot.",
    created_at: reply_time
  )
  conversation.update_columns(created_at: request_time, updated_at: reply_time)

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

puts "Adding day offs to InkMaster's schedule..."
artist_profile.update!(
  schedule: artist_profile.schedule.merge(
    "days_off" => artist_profile.schedule["days_off"] + [ (Date.current + 20).to_s, (Date.current + 30).to_s ]
  )
)

puts "Creating a second address for InkMaster, each with its own weekly hours..."
address2 = Address.create!(
  artist_profile: artist_profile,
  label: "Riverside studio",
  street: "12 Quai de Valmy",
  zipcode: "75010",
  city: "Paris"
)

main_schedule = {
  "slot_duration" => 45,
  "period_start" => Date.current.to_s,
  "period_end" => (Date.current + 6.months).to_s,
  "days" => {
    "monday" => { "start" => "09:00", "end" => "17:00" },
    "tuesday" => { "start" => "10:00", "end" => "18:00" },
    "wednesday" => nil,
    "thursday" => { "start" => "09:00", "end" => "17:00" },
    "friday" => { "start" => "09:00", "end" => "16:00" },
    "saturday" => { "start" => "10:00", "end" => "14:00" },
    "sunday" => nil
  },
  "days_off" => [
    (Date.current + 20).to_s, (Date.current + 30).to_s, (Date.current + 40).to_s,
    "2026-12-24", "2026-12-25", "2026-12-31"
  ]
}

riverside_schedule = {
  "slot_duration" => 60,
  "period_start" => Date.current.to_s,
  "period_end" => (Date.current + 6.months).to_s,
  "days" => {
    "monday" => nil,
    "tuesday" => { "start" => "11:00", "end" => "19:00" },
    "wednesday" => nil,
    "thursday" => { "start" => "11:00", "end" => "19:00" },
    "friday" => { "start" => "11:00", "end" => "18:00" },
    "saturday" => nil,
    "sunday" => nil
  },
  "days_off" => [ (Date.current + 8).to_s, (Date.current + 22).to_s ]
}

address.update!(schedule: main_schedule)
address2.update!(schedule: riverside_schedule)

puts "Creating extra clients for InkMaster bookings..."

# A client with an active booking (selected/artist_confirmed/confirmed) can't be given
# another booking of any status, so this pool is reserved for exactly one active booking
# each; completed/cancelled history draws from a separate, freely-reusable pool below.
inkmaster_clients = [
  { username: "claireb",   first_name: "Claire",   last_name: "Bernard" },
  { username: "hugom",     first_name: "Hugo",     last_name: "Martin" },
  { username: "leadub",    first_name: "Lea",      last_name: "Dubois" },
  { username: "tomp",      first_name: "Tom",      last_name: "Petit" },
  { username: "ninar",     first_name: "Nina",     last_name: "Roux" },
  { username: "maximel",   first_name: "Maxime",   last_name: "Leroy" },
  { username: "chloeb",    first_name: "Chloe",    last_name: "Blanc" },
  { username: "victorm",   first_name: "Victor",   last_name: "Moreau" },
  { username: "juliettef", first_name: "Juliette", last_name: "Fournier" },
  { username: "antoineg",  first_name: "Antoine",  last_name: "Girard" },
  { username: "sarahl",    first_name: "Sarah",    last_name: "Lambert" },
  { username: "romaind",   first_name: "Romain",   last_name: "David" },
  { username: "camillet",  first_name: "Camille",  last_name: "Thomas" },
  { username: "lucasr",    first_name: "Lucas",    last_name: "Robert" },
  { username: "emmar",     first_name: "Emma",     last_name: "Richard" },
  { username: "paulb",     first_name: "Paul",     last_name: "Bonnet" },
  { username: "ines",      first_name: "Ines",     last_name: "Simon" },
  { username: "theom",     first_name: "Theo",     last_name: "Mercier" },
  { username: "aliced",    first_name: "Alice",    last_name: "Dumas" },
  { username: "julesv",    first_name: "Jules",    last_name: "Vidal" },
  { username: "margauxc",  first_name: "Margaux",  last_name: "Colin" },
  { username: "noaht",     first_name: "Noah",     last_name: "Traore" }
].map do |data|
  User.create!(
    email: "#{data[:username]}@test.local",
    password: "password",
    username: data[:username],
    first_name: data[:first_name],
    last_name: data[:last_name],
    birthdate: rand(20..45).years.ago
  )
end

inkmaster_history_clients = [
  { username: "oceaneh",  first_name: "Oceane",  last_name: "Henry" },
  { username: "gabrield", first_name: "Gabriel", last_name: "Durand" },
  { username: "manonp",   first_name: "Manon",   last_name: "Perrin" },
  { username: "nathanb",  first_name: "Nathan",  last_name: "Bertrand" },
  { username: "lounaf",   first_name: "Louna",   last_name: "Faure" },
  { username: "adamg",    first_name: "Adam",    last_name: "Girard" },
  { username: "jadeh",    first_name: "Jade",    last_name: "Renard" },
  { username: "liamf",    first_name: "Liam",    last_name: "Fontaine" }
].map do |data|
  User.create!(
    email: "#{data[:username]}@test.local",
    password: "password",
    username: data[:username],
    first_name: data[:first_name],
    last_name: data[:last_name],
    birthdate: rand(20..45).years.ago
  )
end

# Description paired with the duration it implies, so a booking's slot length always
# matches the size of the project once the artist has confirmed a duration.
booking_options = [
  { description: "Small blackwork geometric piece on the ankle.", duration: 60 },
  { description: "Fine line botanical design wrapping the forearm.", duration: 90 },
  { description: "Traditional anchor with banner on the calf.", duration: 75 },
  { description: "Dotwork mandala on the shoulder blade.", duration: 120 },
  { description: "Minimalist line art of a mountain range on the ribs.", duration: 45 },
  { description: "Cover-up consultation for an old tribal piece.", duration: 30 },
  { description: "Watercolor-style floral piece on the thigh.", duration: 105 },
  { description: "Geometric wolf head on the upper arm.", duration: 90 },
  { description: "Script quote along the collarbone.", duration: 45 },
  { description: "Japanese wave panel on the back, second session.", duration: 180 },
  { description: "Small blackwork snake wrapping the wrist.", duration: 60 },
  { description: "Fine line portrait touch-up session.", duration: 60 },
  { description: "Neo-traditional rose on the bicep.", duration: 75 },
  { description: "Abstract linework sleeve, second session.", duration: 150 },
  { description: "Dotwork sacred geometry on the sternum.", duration: 120 },
  { description: "Realism eye piece on the forearm, first session.", duration: 105 },
  { description: "Small lettering piece behind the ear.", duration: 30 },
  { description: "Blackwork half sleeve, third session.", duration: 180 },
  { description: "Geometric fox silhouette on the calf.", duration: 60 },
  { description: "Fine line constellation on the shoulder.", duration: 45 }
]

artist_replies = [
  "Thanks for reaching out! That sounds like a great project, let me check my calendar.",
  "I love this idea, let's make it happen. I'll confirm a duration shortly.",
  "Got it, thanks for the details! I'll get back to you today.",
  "Perfect, I've already got some good references for that style."
]
client_followups = [
  "Sounds good, thank you!",
  "Perfect, see you then!",
  "Great, thanks for confirming!",
  "Awesome, looking forward to it."
]

def seed_weekday_open?(schedule, date)
  return false if (schedule["days_off"] || []).include?(date.to_s)

  schedule.dig("days", date.strftime("%A").downcase).present?
end

# Walks forward (step: 1) or backward (step: -1) from the given address's cursor until
# it finds a day that's actually open per that address's own weekly hours/days off, so
# every seeded booking lands on a time the artist has really made himself available.
def seed_next_offset(schedule, cursors, address, step, used_offsets)
  offset = cursors[address]
  loop do
    date = offset >= 0 ? offset.days.from_now.to_date : offset.abs.days.ago.to_date
    if seed_weekday_open?(schedule, date) && !used_offsets.include?(offset)
      used_offsets << offset
      cursors[address] = offset + step
      return offset
    end
    offset += step
  end
end

def seed_slot_start(schedule, offset, duration)
  date = offset >= 0 ? offset.days.from_now.to_date : offset.abs.days.ago.to_date
  day_config = schedule.dig("days", date.strftime("%A").downcase)
  window_start = Time.parse(day_config["start"])
  window_end = Time.parse(day_config["end"])
  slack = ((window_end - window_start) / 60).to_i - duration
  padding = slack.positive? ? [ 0, 30, 60 ].select { |m| m <= slack }.sample : 0

  date.in_time_zone.change(hour: window_start.hour, min: window_start.min) + padding.minutes
end

def seed_conversation_thread(conversation, client, artist_user, description, request_time, artist_replies:, client_followups:)
  return if conversation.messages.exists?

  conversation.messages.create!(
    user: client, body: "Hi! I'd love to book a session: #{description}", created_at: request_time
  )
  last_time = request_time

  if rand < 0.5
    last_time = [ last_time + rand(2..20).hours, Time.current ].min
    conversation.messages.create!(user: artist_user, body: artist_replies.sample, created_at: last_time)

    if rand < 0.5
      last_time = [ last_time + rand(1..24).hours, Time.current ].min
      conversation.messages.create!(user: client, body: client_followups.sample, created_at: last_time)
    end
  end

  conversation.update_columns(created_at: request_time, updated_at: last_time)
end

def seed_booking(address:, schedule:, client:, artist_user:, offset:, status:, option:, artist_replies:, client_followups:)
  duration = status == :selected ? (schedule["slot_duration"] || 45) : option[:duration]
  starts_at = seed_slot_start(schedule, offset, duration)
  artist_profile = address.artist_profile

  conversation = Conversation.find_or_create_by!(client: client, artist_profile: artist_profile)
  request_time = [ starts_at - rand(2..10).days, Time.current - rand(1..5).days ].min
  seed_conversation_thread(conversation, client, artist_user, option[:description], request_time,
                            artist_replies: artist_replies, client_followups: client_followups)

  availability = artist_profile.availabilities.create!(
    address: address,
    starts_at: starts_at,
    ends_at: starts_at + duration.minutes,
    state: %i[confirmed completed cancelled].include?(status) ? :booked : :open
  )

  availability.build_booking(
    client: client,
    description: option[:description],
    duration: status == :selected ? nil : duration,
    status: status
  ).save!
end

puts "Creating a large batch of InkMaster bookings across both addresses..."

addresses = [ address, address2 ]
schedules = [ main_schedule, riverside_schedule ]

# Picks the next Friday (and the Saturday right after it) that are both actually open on
# the main schedule, relative to Date.current — used below for the hand-written "demo
# week" bookings, so those never drift into a hardcoded date that no longer makes sense.
sept_fri_offset = 1
loop do
  sept_fri_offset += 1 until sept_fri_offset.days.from_now.wday == 5
  fri_date = sept_fri_offset.days.from_now.to_date
  break if seed_weekday_open?(main_schedule, fri_date) && seed_weekday_open?(main_schedule, fri_date + 1)

  sept_fri_offset += 7
end
sept_sat_offset = sept_fri_offset + 1

# Days already used by the two hand-written "confirmed" bookings, the 3 legacy open
# availabilities created above, and the Friday/Saturday demo bookings created further
# down, so the generator below never lands on the same day.
used_offsets = [ 1, 2, 3, fred_offset, sam_offset, sept_fri_offset, sept_sat_offset ]
future_cursors = { address => 1, address2 => 1 }
past_cursors = { address => -1, address2 => -1 }

def seed_batch(count, clients, status, addresses, schedules, cursors, step, used_offsets, booking_options,
               artist_user, artist_replies, client_followups)
  count.times do |i|
    idx = i.even? ? 0 : 1
    addr, sched = addresses[idx], schedules[idx]
    offset = seed_next_offset(sched, cursors, addr, step, used_offsets)
    seed_booking(address: addr, schedule: sched, client: clients[i], artist_user: artist_user, offset: offset,
                 status: status, option: booking_options.sample, artist_replies: artist_replies,
                 client_followups: client_followups)
  end
end

# Pending requests, awaiting the artist's response — spread across both addresses
seed_batch(6, inkmaster_clients[0, 6], :selected, addresses, schedules, future_cursors, 1, used_offsets,
           booking_options, artist_user, artist_replies, client_followups)

# Duration set by the artist, awaiting the client's confirmation
seed_batch(4, inkmaster_clients[6, 4], :artist_confirmed, addresses, schedules, future_cursors, 1, used_offsets,
           booking_options, artist_user, artist_replies, client_followups)

# Confirmed sessions over the coming weeks, for agenda navigation
seed_batch(8, inkmaster_clients[10, 8], :confirmed, addresses, schedules, future_cursors, 1, used_offsets,
           booking_options, artist_user, artist_replies, client_followups)

# Confirmed sessions already past, still needing to be marked completed
seed_batch(4, inkmaster_clients[18, 4], :confirmed, addresses, schedules, past_cursors, -1, used_offsets,
           booking_options, artist_user, artist_replies, client_followups)

history_pool = inkmaster_history_clients.cycle

# Completed sessions, for the History view + CSV export
seed_batch(16, history_pool.first(16), :completed, addresses, schedules, past_cursors, -1, used_offsets,
           booking_options, artist_user, artist_replies, client_followups)

# Cancelled bookings
seed_batch(6, history_pool.first(6), :cancelled, addresses, schedules, past_cursors, -1, used_offsets,
           booking_options, artist_user, artist_replies, client_followups)

puts "Adding extra same-day bookings for today, tomorrow, and the day after..."

# inkmaster_history_clients only carry completed/cancelled bookings so far, so they're
# free to also take on one of these extra confirmed sessions each.
same_day_clients = inkmaster_history_clients.dup

# Skips whichever of today/tomorrow/day-after happens to be the reserved Friday or
# Saturday demo day below, so this filler never competes with those hand-written bookings.
([ 0, 1, 2 ] - [ sept_fri_offset, sept_sat_offset ]).each do |offset|
  date = offset.days.from_now.to_date
  addr = seed_weekday_open?(main_schedule, date) ? address : address2
  next unless seed_weekday_open?(addr.schedule, date)

  2.times do
    client = same_day_clients.shift
    next unless client

    option = booking_options.sample
    day_start = Time.parse(addr.schedule.dig("days", date.strftime("%A").downcase)["start"])
    desired_start = date.in_time_zone.change(hour: day_start.hour, min: day_start.min)
    slot = Availability.next_available_slot(artist_profile: artist_profile, starts_at: desired_start,
                                             ends_at: desired_start + option[:duration].minutes, schedule: addr.schedule)
    next unless slot

    conversation = Conversation.find_or_create_by!(client: client, artist_profile: artist_profile)
    request_time = [ slot[:starts_at] - rand(2..10).days, Time.current - rand(1..5).days ].min
    seed_conversation_thread(conversation, client, artist_user, option[:description], request_time,
                              artist_replies: artist_replies, client_followups: client_followups)

    availability = artist_profile.availabilities.create!(
      address: addr, starts_at: slot[:starts_at], ends_at: slot[:ends_at], state: :booked
    )
    availability.build_booking(client: client, description: option[:description], duration: option[:duration],
                                status: :confirmed).save!
  end
end

puts "Adding InkMaster confirmed bookings for the upcoming Friday and Saturday..."

sept_clients = [
  { username: "florad", first_name: "Flora", last_name: "Dubois" },
  { username: "hugotr", first_name: "Hugo",  last_name: "Trentin" },
  { username: "ninaqc", first_name: "Nina",  last_name: "Quach" },
  { username: "leom",   first_name: "Leo",   last_name: "Marchetti" },
  { username: "saral",  first_name: "Sara",  last_name: "Lenoir" }
].map do |data|
  User.create!(
    email: "#{data[:username]}@test.local", password: "password", username: data[:username],
    first_name: data[:first_name], last_name: data[:last_name], birthdate: rand(20..45).years.ago
  )
end

sept_friday = sept_fri_offset.days.from_now.to_date
sept_saturday = sept_sat_offset.days.from_now.to_date

sept_bookings = [
  { date: sept_friday, hour: 9, client: sept_clients[0], duration: 60,
    description: "Small blackwork script on the ribs." },
  { date: sept_friday, hour: 11, client: sept_clients[1], duration: 75,
    description: "Geometric dotwork pattern on the forearm." },
  { date: sept_friday, hour: 13, client: sept_clients[2], duration: 60,
    description: "Fine line botanical piece on the shoulder." },
  { date: sept_saturday, hour: 10, client: sept_clients[3], duration: 45,
    description: "Blackwork sleeve, second session." },
  { date: sept_saturday, hour: 12, client: sept_clients[4], duration: 60,
    description: "Small dotwork mandala on the wrist." }
]

sept_bookings.each do |data|
  desired_start = data[:date].in_time_zone.change(hour: data[:hour])
  slot = Availability.next_available_slot(artist_profile: artist_profile, starts_at: desired_start,
                                           ends_at: desired_start + data[:duration].minutes, schedule: address.schedule)
  raise "No slot available near #{data[:date]} #{data[:hour]}:00 for InkMaster" unless slot

  conversation = Conversation.find_or_create_by!(client: data[:client], artist_profile: artist_profile)
  request_time = [ slot[:starts_at] - rand(3..15).days, Time.current - rand(1..10).days ].min
  seed_conversation_thread(conversation, data[:client], artist_user, data[:description], request_time,
                            artist_replies: artist_replies, client_followups: client_followups)

  availability = artist_profile.availabilities.create!(
    address: address, starts_at: slot[:starts_at], ends_at: slot[:ends_at], state: :booked
  )
  availability.build_booking(client: data[:client], description: data[:description],
                              duration: data[:duration], status: :confirmed).save!
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

def find_artist_profile(username)
  ArtistProfile.joins(:user).find_by!(users: { username: username })
end

puts "Opening slots for Kai Irezumi and Maison Sumi, Tuesday to Saturday 10:00-20:00..."
tue_sat_schedule = {
  "slot_duration" => 60,
  "period_start" => Date.current.to_s,
  "period_end" => (Date.current + 6.months).to_s,
  "days" => {
    "monday" => nil,
    "tuesday" => { "start" => "10:00", "end" => "20:00" },
    "wednesday" => { "start" => "10:00", "end" => "20:00" },
    "thursday" => { "start" => "10:00", "end" => "20:00" },
    "friday" => { "start" => "10:00", "end" => "20:00" },
    "saturday" => { "start" => "10:00", "end" => "20:00" },
    "sunday" => nil
  },
  "days_off" => []
}
%w[kaiirezumi maisonsumi].each do |username|
  find_artist_profile(username).addresses.first.update!(schedule: tue_sat_schedule)
end

puts "Adding tattoolover's bookings, likes, and conversations across several artists..."

# Nudges a (possibly negative) day offset away from zero until it lands on a weekday
# that isn't in closed_wdays (0 = Sunday ... 6 = Saturday) — same idea as the InkMaster
# next_open_weekday helper above, generalized to any set of closed days and either
# direction in time.
nudge_to_open_day = ->(offset, closed_wdays) {
  loop do
    date = offset >= 0 ? offset.days.from_now : offset.abs.days.ago
    break offset unless closed_wdays.include?(date.wday)

    offset += offset >= 0 ? 1 : -1
  end
}
sun_mon = [ 0, 1 ]

tattoolover_bookings = [
  { artist: "inkline", status: :selected, offset: 4, hour: 14, duration: 60,
    description: "Small blackwork script along the collarbone." },
  { artist: "noiretgris", status: :artist_confirmed, offset: 7, hour: 15, duration: 90,
    description: "Black and grey portrait piece on the upper arm." },
  { artist: "kaiirezumi", status: :confirmed, offset: nudge_to_open_day.call(10, sun_mon), hour: 12, duration: 120,
    description: "Irezumi-style koi panel, first session." },
  { artist: "maisonsumi", status: :completed, offset: nudge_to_open_day.call(-15, sun_mon), hour: 13, duration: 90,
    description: "Fine line koi and wave motif on the calf." },
  { artist: "mnemosyne", status: :completed, offset: -28, hour: 16, duration: 150,
    description: "Surrealist eye-and-moon composition on the ribs." },
  { artist: "sionink", status: :cancelled, offset: -6, hour: 11, duration: 60,
    description: "Traditional swallow flash on the forearm." }
]

tattoolover_bookings.each do |data|
  profile = find_artist_profile(data[:artist])
  address = profile.addresses.first
  starts_at = data[:offset] >= 0 ? data[:offset].days.from_now.change(hour: data[:hour]) :
                                    data[:offset].abs.days.ago.change(hour: data[:hour])

  conversation = Conversation.find_or_create_by!(client: client_user, artist_profile: profile)
  request_time = [ starts_at - rand(3..10).days, Time.current - rand(2..20).days ].min
  seed_conversation_thread(conversation, client_user, profile.user, data[:description], request_time,
                            artist_replies: artist_replies, client_followups: client_followups)

  if data[:status] == :completed
    last_message = conversation.messages.order(:created_at).last
    follow_up_time = [ last_message.created_at + rand(1..3).days, Time.current ].min
    conversation.messages.create!(
      user: client_user, body: "Thanks again, I love how it turned out!", created_at: follow_up_time
    )
    conversation.update_column(:updated_at, follow_up_time)
  end

  availability = profile.availabilities.create!(
    address: address, starts_at: starts_at, ends_at: starts_at + data[:duration].minutes,
    state: %i[confirmed completed cancelled].include?(data[:status]) ? :booked : :open
  )
  availability.build_booking(client: client_user, description: data[:description],
                              duration: data[:status] == :selected ? nil : data[:duration],
                              status: data[:status]).save!
end

%w[inkline kaiirezumi boldlines atelier9 encrenoire].each do |username|
  Like.create!(user: client_user, artist_profile: find_artist_profile(username))
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
