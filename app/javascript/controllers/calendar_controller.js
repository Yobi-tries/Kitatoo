import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popup", "popupTitle", "popupSlots"]

  showSlots(event) {
    const date = event.params.date
    const slots = event.params.slots

    this.popupTitleTarget.textContent = date
    this.popupSlotsTarget.innerHTML = slots
      .map(slot => `<div class="calendar-slot">${slot}</div>`)
      .join("")

    this.popupTarget.classList.remove("d-none")
  }

  hideSlots() {
    this.popupTarget.classList.add("d-none")
  }
}
