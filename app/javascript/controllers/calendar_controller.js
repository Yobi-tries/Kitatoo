import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popup", "popupTitle", "popupSlots", "startsAt", "endsAt", "selected"]

  showSlots(event) {
    const date = event.params.date
    const slots = event.params.slots

    this.popupTitleTarget.textContent = date
    this.popupSlotsTarget.innerHTML = slots
      .map(slot => `
        <label class="calendar-slot">
          <input type="radio" name="calendar-slot" value="${slot.starts_at}|${slot.ends_at}"
                 data-action="change->calendar#selectSlot" data-label="${date}, ${slot.label}">
          ${slot.label}
        </label>
      `)
      .join("")

    this.popupTarget.classList.remove("d-none")
  }

  selectSlot(event) {
    const [startsAt, endsAt] = event.target.value.split("|")
    this.startsAtTarget.value = startsAt
    this.endsAtTarget.value = endsAt
    this.selectedTarget.textContent = `Selected: ${event.target.dataset.label}`
    this.hideSlots()
  }

  hideSlots() {
    this.popupTarget.classList.add("d-none")
  }
}
