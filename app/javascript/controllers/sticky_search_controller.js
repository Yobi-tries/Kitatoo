import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar", "placeholder"]

  connect() {
    if (!this.hasBarTarget || !this.hasPlaceholderTarget) return

    this.docked = false
    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting && !this.docked) {
          this.dock()
        } else if (entry.isIntersecting && this.docked) {
          this.undock()
        }
      },
      { threshold: 0, rootMargin: "-64px 0px 0px 0px" }
    )
    this.observer.observe(this.placeholderTarget)
  }

  disconnect() {
    this.observer?.disconnect()
    if (this.docked) this.undock()
  }

  dock() {
    this.docked = true
    const rect = this.barTarget.getBoundingClientRect()
    this.placeholderTarget.style.height = `${rect.height}px`
    this.barTarget.classList.add("home-search--docked")
  }

  undock() {
    this.docked = false
    this.placeholderTarget.style.height = ""
    this.barTarget.classList.remove("home-search--docked")
  }
}
