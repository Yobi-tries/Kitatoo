import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "image"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.imageTarget.src = e.target.result
      this.previewTarget.classList.remove("d-none")
    }
    reader.readAsDataURL(file)
  }

  remove() {
    this.inputTarget.value = ""
    this.previewTarget.classList.add("d-none")
    this.imageTarget.src = ""
  }

  reset() {
    this.element.reset()
    this.remove()
  }
}
