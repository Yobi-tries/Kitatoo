import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "generationIdInput", "preview", "uploadField",
    "bodyPhotoInput", "bodyPreview", "bodyUploadField", "bodyPreviewCard"
  ]

  useGenerated(event) {
    const { imageUrl, generationId } = event.params

    this.generationIdInputTarget.value = generationId
    this.#revoke("designObjectUrl")
    this.previewTarget.src = imageUrl
    this.previewTarget.classList.remove("d-none")
    this.uploadFieldTarget.classList.add("d-none")

    this.dispatch("open-card", { target: this.bodyPreviewCardTarget })
    this.element.querySelector("#body_preview_form")?.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  designImageSelected(event) {
    const file = event.target.files[0]
    if (!file) return

    this.generationIdInputTarget.value = ""
    this.#revoke("designObjectUrl")
    this.designObjectUrl = URL.createObjectURL(file)

    this.previewTarget.src = this.designObjectUrl
    this.previewTarget.classList.remove("d-none")
    this.uploadFieldTarget.classList.add("d-none")
  }

  bodyPhotoSelected(event) {
    const file = event.target.files[0]
    if (!file) return

    this.#revoke("bodyPhotoObjectUrl")
    this.bodyPhotoObjectUrl = URL.createObjectURL(file)

    this.bodyPreviewTarget.src = this.bodyPhotoObjectUrl
    this.bodyPreviewTarget.classList.remove("d-none")
    this.bodyUploadFieldTarget.classList.add("d-none")
  }

  disconnect() {
    this.#revoke("designObjectUrl")
    this.#revoke("bodyPhotoObjectUrl")
  }

  #revoke(key) {
    if (this[key]) {
      URL.revokeObjectURL(this[key])
      this[key] = null
    }
  }
}
