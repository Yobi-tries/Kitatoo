import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["description", "summary", "summaryDate", "summaryLocation", "submit"]

  connect() {
    this.slotLabel = null
    this.update()
  }

  onSlotSelected(event) {
    this.slotLabel = event.detail.label
    this.update()
  }

  update() {
    if (this.slotLabel) {
      this.summaryDateTarget.textContent = this.slotLabel
    } else {
      this.summaryDateTarget.textContent = "Pick a slot above"
    }

    this.submitTarget.disabled = !this.slotLabel
  }
}
