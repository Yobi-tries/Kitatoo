import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popup", "popupTitle", "popupSlots", "startsAt", "endsAt", "day"]
  static values = { prefillStartsAt: String, prefillEndsAt: String, prefillLabel: String }

  connect() {
    if (this.prefillStartsAtValue && this.prefillEndsAtValue) {
      this.startsAtTarget.value = this.prefillStartsAtValue
      this.endsAtTarget.value = this.prefillEndsAtValue
      this.dispatch("slotSelected", { detail: { label: this.prefillLabelValue }, bubbles: true })
      this.#selectDayByIso(this.prefillStartsAtValue.slice(0, 10))
    }
  }

  showSlots(event) {
    const date = event.params.date
    const slots = event.params.slots

    this.popupTitleTarget.textContent = `Available times for ${date}`
    this.popupSlotsTarget.innerHTML = this.#groupedSlotsHtml(slots, date)
    this.popupTarget.classList.remove("d-none")
    this.#selectDay(event.currentTarget)
  }

  #selectDay(dayEl) {
    this.element.querySelectorAll(".calendar-day--selected, .calendar-day--today")
      .forEach((el) => el.classList.remove("calendar-day--selected", "calendar-day--today"))
    dayEl.classList.add("calendar-day--selected")
  }

  #selectDayByIso(iso) {
    const match = this.dayTargets.find((el) => el.dataset.calendarDayParam === iso)
    if (match) this.#selectDay(match)
  }

  selectSlot(event) {
    const [ startsAt, endsAt ] = event.target.value.split("|")
    this.startsAtTarget.value = startsAt
    this.endsAtTarget.value = endsAt
    this.dispatch("slotSelected", { detail: { label: event.target.dataset.label }, bubbles: true })
  }

  #groupedSlotsHtml(slots, date) {
    const groups = { Morning: [], Afternoon: [], Evening: [] }
    slots.forEach((slot) => {
      const hour = parseInt(slot.label.split(":")[0], 10)
      const period = hour < 12 ? "Morning" : hour < 17 ? "Afternoon" : "Evening"
      groups[period].push(slot)
    })

    return Object.entries(groups)
      .filter(([ , slotsInGroup ]) => slotsInGroup.length > 0)
      .map(([ period, slotsInGroup ]) => `
        <div class="calendar-slot-group">
          <p class="calendar-slot-group-title">${period}</p>
          <div class="calendar-slot-row">
            ${slotsInGroup.map((slot) => `
              <label class="calendar-slot">
                <input type="radio" name="calendar-slot" value="${slot.starts_at}|${slot.ends_at}"
                       class="visually-hidden" data-action="change->calendar#selectSlot" data-label="${date}, ${slot.label}">
                ${slot.label}
              </label>
            `).join("")}
          </div>
        </div>
      `)
      .join("")
  }
}
