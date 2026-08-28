module CalendarHelper
  def calendar_weeks(month)
    start_date = month.beginning_of_month.beginning_of_week(:monday)
    end_date = month.end_of_month.end_of_week(:monday)
    (start_date..end_date).to_a.each_slice(7).to_a
  end

  def available_day?(schedule, date)
    return false unless schedule
    period_start = Date.parse(schedule["period_start"]) rescue nil
    period_end = Date.parse(schedule["period_end"]) rescue nil
    return false unless period_start && period_end
    return false unless date.between?(period_start, period_end)
    return false if (schedule["days_off"] || []).include?(date.to_s)

    day_name = date.strftime("%A").downcase
    schedule.dig("days", day_name).present?
  end
  module_function :available_day?

  def slots_for_day(schedule, date, artist_profile: nil)
    return [] unless available_day?(schedule, date)

    day_config = schedule.dig("days", date.strftime("%A").downcase)
    duration = (schedule["slot_duration"] || 60).to_i
    start_time = Time.parse(day_config["start"])
    end_time = Time.parse(day_config["end"])

    booked_ranges = booked_ranges_for_day(date, artist_profile)

    slots = []
    current = start_time
    while current + duration.minutes <= end_time
      slot_start = current
      slot_end = current + duration.minutes

      conflict = booked_ranges.find { |r| Availability.ranges_overlap?(slot_start, slot_end, r[:start], r[:end]) }

      if conflict
        current = ceil_to_quarter_hour([current + 15.minutes, conflict[:end]].max)
        next
      end

      slots << {
        label: slot_start.strftime('%H:%M'),
        starts_at: date.to_time.change(hour: slot_start.hour, min: slot_start.min).iso8601,
        ends_at: date.to_time.change(hour: slot_end.hour, min: slot_end.min).iso8601
      }
      current += duration.minutes
    end
    slots
  end

  def ceil_to_quarter_hour(time)
    remainder = time.min % 15
    return time if remainder.zero?

    time + (15 - remainder).minutes
  end

  def booked_ranges_for_day(date, artist_profile)
    return [] unless artist_profile

    default_duration = (artist_profile.schedule&.dig("slot_duration") || 30).to_i

    bookings = Booking.joins(:availability)
                      .where(availabilities: { artist_profile_id: artist_profile.id })
                      .where.not(status: :cancelled)

    bookings.filter_map do |booking|
      booking_date = booking.availability.starts_at.to_date
      next unless booking_date == date

      duration = booking.duration || default_duration
      start_time = Time.parse(booking.availability.starts_at.strftime("%H:%M"))
      end_time = start_time + duration.minutes
      { start: start_time, end: end_time }
    end
  end
end
