import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { userId: Number }

  connect() {
    this.styleMessages()
    this.observer = new MutationObserver(() => this.styleMessages())
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  styleMessages() {
    this.element.querySelectorAll(".message-group").forEach(msg => {
      const senderId = parseInt(msg.dataset.senderId)
      const outgoing = senderId === this.userIdValue
      msg.classList.toggle("message-group--outgoing", outgoing)
      msg.classList.toggle("message-group--incoming", !outgoing)
      const bubble = msg.querySelector(".message-bubble")
      if (bubble) {
        bubble.classList.toggle("message-bubble--outgoing", outgoing)
        bubble.classList.toggle("message-bubble--incoming", !outgoing)
      }
    })
  }
}
