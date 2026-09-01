import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["generationIdInput", "preview", "uploadField"]

  useGenerated(event) {
    const { imageUrl, generationId } = event.params

    this.generationIdInputTarget.value = generationId
    this.previewTarget.src = imageUrl
    this.previewTarget.classList.remove("d-none")
    this.uploadFieldTarget.classList.add("d-none")

    this.element.querySelector("#body_preview_result")?.scrollIntoView({ behavior: "smooth", block: "start" })
  }
}
