import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "previews", "addTile"]
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
    this.addTileTarget.classList.toggle("d-none", this.files.length >= this.maxValue)
  }

  #renderPreviews() {
    this.previewsTarget.innerHTML = this.files
      .map(
        (file, index) => `
          <div class="reference-thumb">
            <img src="${URL.createObjectURL(file)}">
            <button type="button" class="reference-thumb-remove" data-action="reference-images#remove" data-index="${index}">
              <i class="fa-solid fa-xmark"></i>
            </button>
          </div>
        `
      )
      .join("")
  }
}
