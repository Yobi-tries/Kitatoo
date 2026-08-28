import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "button"]
  static values = { limit: { type: Number, default: 5 }, max: { type: Number, default: 10 } }

  reveal() {
    this.itemTargets.forEach((item, index) => {
      if (index < this.maxValue) item.style.display = ""
    })
    this.buttonTarget.style.display = "none"
  }
}
