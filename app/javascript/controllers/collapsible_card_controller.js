import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content"]

  connect() {
    this.close()
  }

  toggle() {
    this.contentTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.contentTarget.hidden = false
  }

  close() {
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.contentTarget.hidden = true
  }
}
