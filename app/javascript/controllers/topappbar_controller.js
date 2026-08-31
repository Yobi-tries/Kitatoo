import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollHandler = () => {
      this.element.classList.toggle("topappbar--scrolled", window.scrollY > 10)
    }
    window.addEventListener("scroll", this.scrollHandler, { passive: true })
    this.scrollHandler()
  }

  disconnect() {
    window.removeEventListener("scroll", this.scrollHandler)
    this.element.classList.remove("topappbar--scrolled")
  }
}
