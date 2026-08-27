Geocoder.configure(
  timeout: 5,
  lookup: :mapbox,
  api_key: ENV["MAPBOX_API_KEY"],
  units: :km
)
