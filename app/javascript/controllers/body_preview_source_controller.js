import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "generationIdInput", "preview", "previewWrap", "uploadField", "designPhotoInput",
    "bodyPhotoInput", "bodyPreview", "bodyPreviewWrap", "bodyUploadField", "bodyPreviewCard"
  ]

  useGenerated(event) {
    const { imageUrl, generationId } = event.params

    this.generationIdInputTarget.value = generationId
    this.#revoke("designObjectUrl")
    this.previewTarget.src = imageUrl
    this.previewWrapTarget.classList.remove("d-none")
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
    this.previewWrapTarget.classList.remove("d-none")
    this.uploadFieldTarget.classList.add("d-none")
  }

  bodyPhotoSelected(event) {
    const file = event.target.files[0]
    if (!file) return

    this.#revoke("bodyPhotoObjectUrl")
    this.bodyPhotoObjectUrl = URL.createObjectURL(file)

    this.bodyPreviewTarget.src = this.bodyPhotoObjectUrl
    this.bodyPreviewWrapTarget.classList.remove("d-none")
    this.bodyUploadFieldTarget.classList.add("d-none")
  }

  removeDesign() {
    this.generationIdInputTarget.value = ""
    this.#revoke("designObjectUrl")
    this.designPhotoInputTarget.value = ""

    this.previewTarget.src = ""
    this.previewWrapTarget.classList.add("d-none")
    this.uploadFieldTarget.classList.remove("d-none")
  }

  removeBodyPhoto() {
    this.#revoke("bodyPhotoObjectUrl")
    this.bodyPhotoInputTarget.value = ""

    this.bodyPreviewTarget.src = ""
    this.bodyPreviewWrapTarget.classList.add("d-none")
    this.bodyUploadFieldTarget.classList.remove("d-none")
  }

  // "Try another photo": keep the generated result visible, only reset the
  // two source inputs so the form is ready for a fresh submission.
  resetSources() {
    this.removeDesign()
    this.removeBodyPhoto()
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
