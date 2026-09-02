import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["title", "confirmButton"]

  connect() {
    Turbo.config.forms.confirm = this.confirmTurboNavigation.bind(this)
  }

  confirmTurboNavigation(message, formElement, submitter) {
    this.titleTarget.textContent = message
    this.confirmButtonTarget.textContent =
      submitter?.dataset.confirmButtonLabel || formElement?.dataset.confirmButtonLabel || "Confirm"
    this.element.showModal()

    return new Promise((resolve) => {
      this.element.addEventListener(
        "close",
        () => resolve(this.element.returnValue === "confirm"),
        { once: true }
      )
    })
  }

  onBackdropClick(event) {
    if (event.target === this.element) this.element.close()
  }
}
