import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]

  open(event) {
    const index = Number(event.currentTarget.dataset.albumIndex)
    this.slideTargets.forEach((slide, position) => {
      slide.classList.toggle("active", position === index)
    })
  }
}
