import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar", "placeholder"]

  connect() {
    if (!this.hasBarTarget || !this.hasPlaceholderTarget) return

    this.bar = this.barTarget
    this.placeholder = this.placeholderTarget
    this.topappbarSearchBtn = document.querySelector(".topappbar-search-btn")
    this.searchOverlay = document.querySelector(".search-modal-overlay")
    this.searchBar = document.querySelector(".search-modal-bar")

    this.docked = false

    // Hide the topappbar search button on homepage (we use the inline one)
    if (this.topappbarSearchBtn) this.topappbarSearchBtn.style.display = "none"

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
    this.observer.observe(this.placeholder)
  }

  disconnect() {
    this.observer?.disconnect()
    if (this.topappbarSearchBtn) this.topappbarSearchBtn.style.display = ""
    if (this.docked) this.undock()
  }

  dock() {
    this.docked = true
    const rect = this.bar.getBoundingClientRect()
    this.placeholder.style.height = `${rect.height}px`
    this.bar.style.display = "none"
    // Show the topappbar search button when inline bar is hidden
    if (this.topappbarSearchBtn) this.topappbarSearchBtn.style.display = ""
    // Update the search modal input with the current query
    if (this.searchBar) {
      const query = this.bar.querySelector("input")?.value || ""
      const modalInput = this.searchBar.querySelector("input")
      if (modalInput) modalInput.value = query
    }
  }

  undock() {
    this.docked = false
    this.bar.style.display = ""
    this.placeholder.style.height = ""
    // Hide the topappbar search button when inline bar is visible
    if (this.topappbarSearchBtn) this.topappbarSearchBtn.style.display = "none"
  }
}
