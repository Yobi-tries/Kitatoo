import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["otherInput"]

  toggleOther(event) {
    const isOther = event.currentTarget.dataset.isOther === "true"
    this.otherInputTarget.classList.toggle("d-none", !isOther)
    this.otherInputTarget.required = isOther
    if (!isOther) this.otherInputTarget.value = ""
  }
}
