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

  def slots_for_day(schedule, date)
    return [] unless available_day?(schedule, date)

    day_config = schedule.dig("days", date.strftime("%A").downcase)
    duration = (schedule["slot_duration"] || 60).to_i
    start_time = Time.parse(day_config["start"])
    end_time = Time.parse(day_config["end"])

    slots = []
    current = start_time
    while current + duration.minutes <= end_time
      slots << "#{current.strftime('%H:%M')} — #{(current + duration.minutes).strftime('%H:%M')}"
      current += duration.minutes
    end
    slots
  end
end
