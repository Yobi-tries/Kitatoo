import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "previews"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    this.files = []
  }

  filesSelected() {
    const incoming = Array.from(this.fileInputTarget.files || []).filter((file) => file.type.startsWith("image/"))
    this.files = this.files.concat(incoming).slice(0, this.maxValue)
    this.#syncInput()
    this.#renderPreviews()
  }

  remove(event) {
    const index = Number(event.currentTarget.dataset.index)
    this.files.splice(index, 1)
    this.#syncInput()
    this.#renderPreviews()
  }

  #syncInput() {
    const transfer = new DataTransfer()
    this.files.forEach((file) => transfer.items.add(file))
    this.fileInputTarget.files = transfer.files
  }

  #renderPreviews() {
    this.previewsTarget.innerHTML = this.files
      .map(
        (file, index) => `
          <div class="position-relative" style="width: 72px; height: 72px;">
            <img src="${URL.createObjectURL(file)}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 8px;">
            <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-1 bg-dark bg-opacity-50 rounded-circle p-1"
                    style="font-size: 0.5rem;" data-action="reference-images#remove" data-index="${index}"></button>
          </div>
        `
      )
      .join("")
  }
}
