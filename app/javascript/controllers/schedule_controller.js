import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dayRow", "timeInput", "daysOffList", "dayOffRow"]

  toggleDay(event) {
    const row = event.currentTarget.closest("[data-schedule-target='dayRow']")
    const inputs = row.querySelectorAll("input[type='time']")
    inputs.forEach(input => {
      input.disabled = !event.currentTarget.checked
      if (!event.currentTarget.checked) input.value = ""
    })
  }

  addDayOff() {
    const index = this.dayOffRowTargets.length
    const chip = document.createElement("div")
    chip.classList.add("schedule-day-off-chip")
    chip.setAttribute("data-schedule-target", "dayOffRow")
    chip.innerHTML = `
      <input type="date" name="artist_profile[schedule][days_off][${index}]"
             class="schedule-day-off-input">
      <button type="button" class="schedule-day-off-remove" data-action="schedule#removeDayOff">✕</button>
    `
    this.daysOffListTarget.appendChild(chip)
  }

  removeDayOff(event) {
    event.currentTarget.closest("[data-schedule-target='dayOffRow']").remove()
  }
}
