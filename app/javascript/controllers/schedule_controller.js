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
    const row = document.createElement("div")
    row.classList.add("schedule-day-off-row")
    row.setAttribute("data-schedule-target", "dayOffRow")
    row.innerHTML = `
      <input type="date" name="artist_profile[schedule][days_off][${index}]"
             class="form-control form-control-sm">
      <button type="button" class="btn btn-outline-danger btn-sm" data-action="schedule#removeDayOff">Remove</button>
    `
    this.daysOffListTarget.appendChild(row)
  }

  removeDayOff(event) {
    event.currentTarget.closest("[data-schedule-target='dayOffRow']").remove()
  }
}
