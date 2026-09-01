import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["guidedPanel", "freeTextPanel"]

  switchMode(event) {
    const guided = event.target.value === "guided"
    this.guidedPanelTarget.classList.toggle("d-none", !guided)
    this.freeTextPanelTarget.classList.toggle("d-none", guided)
  }
}
