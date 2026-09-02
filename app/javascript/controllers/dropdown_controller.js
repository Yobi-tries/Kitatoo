import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    this.panelTarget.hidden = !this.panelTarget.hidden
  }

  closeOnOutsideClick(event) {
    if (!this.panelTarget.hidden && !this.element.contains(event.target)) {
      this.panelTarget.hidden = true
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.panelTarget.hidden = true
  }
}
