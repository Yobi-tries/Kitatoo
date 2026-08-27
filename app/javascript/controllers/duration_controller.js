import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display"]
  static values = { step: { type: Number, default: 30 } }

  increment() {
    const current = parseInt(this.inputTarget.value)
    const next = current + this.stepValue
    this.inputTarget.value = next
    this.displayTarget.textContent = `${next} min`
  }

  decrement() {
    const current = parseInt(this.inputTarget.value)
    const next = current - this.stepValue
    if (next >= this.stepValue) {
      this.inputTarget.value = next
      this.displayTarget.textContent = `${next} min`
    }
  }
}
