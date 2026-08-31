import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.overlay = document.getElementById("searchModalOverlay")
    this.bar = document.getElementById("searchModalBar")
    this.closeHandler = (e) => {
      if (e.target === this.overlay) this.close()
    }
    this.overlay?.addEventListener("click", this.closeHandler)
  }

  disconnect() {
    this.overlay?.removeEventListener("click", this.closeHandler)
  }

  open() {
    this.overlay?.classList.remove("d-none")
    this.bar?.querySelector("input")?.focus()
  }

  close() {
    this.overlay?.classList.add("d-none")
  }
}
