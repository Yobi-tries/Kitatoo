import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["formTemplate"]

  reset() {
    const current = document.getElementById("tattoo_generation_result")
    if (!current) return

    current.replaceWith(this.formTemplateTarget.content.cloneNode(true))
  }
}
