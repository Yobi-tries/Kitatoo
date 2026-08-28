import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "checkbox", "trash", "confirm", "pin", "cover" ]

  enable() {
    this.checkboxTargets.forEach((box) => box.classList.remove("d-none"))
    this.trashTarget.classList.add("d-none")
    this.confirmTarget.classList.remove("d-none")
  }

  pin() {
    this.coverTargets.forEach((link) => link.classList.remove("d-none"))
    this.pinTarget.classList.add("d-none")
  }
}
