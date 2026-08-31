import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  navigate() {
    this.element.requestSubmit()
  }
}
