import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["address", "description", "summary", "submit"]

  connect() {
    this.slotLabel = null
    this.update()
  }

  onSlotSelected(event) {
    this.slotLabel = event.detail.label
    this.update()
  }

  update() {
    const address = this.addressTarget.selectedOptions[0]?.text || "—"
    const description = this.descriptionTarget.value.trim() || "—"

    this.summaryTarget.innerHTML = ""
    this.summaryTarget.append(
      ...this.field("Location", address),
      ...this.field("Date & time", this.slotLabel || "No slot selected yet."),
      ...this.field("Your idea", description)
    )

    this.submitTarget.disabled = !this.slotLabel
  }

  field(label, value) {
    const dt = document.createElement("dt")
    dt.textContent = label
    const dd = document.createElement("dd")
    dd.textContent = value
    return [dt, dd]
  }
}
