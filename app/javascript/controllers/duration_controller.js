import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display"]
  static values = { step: { type: Number, default: 30 } }

  increment() {
    const current = parseInt(this.inputTarget.value)
    const next = Math.min(current + this.stepValue, 240)
    this.inputTarget.value = next
    this.displayTarget.textContent = this.formatDuration(next)
  }

  decrement() {
    const current = parseInt(this.inputTarget.value)
    const next = Math.max(current - this.stepValue, 30)
    this.inputTarget.value = next
    this.displayTarget.textContent = this.formatDuration(next)
  }

  formatDuration(minutes) {
    const h = Math.floor(minutes / 60)
    const m = String(minutes % 60).padStart(2, "0")
    return `${h}h${m}`
  }
}
