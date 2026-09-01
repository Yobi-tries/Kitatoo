import { Controller } from "@hotwired/stimulus"

const USE_FOR_OPTIONS = [
  ["overall", "Overall reference"],
  ["composition", "Composition & pose"],
  ["style", "Style"],
  ["element", "Specific element"]
]

export default class extends Controller {
  static targets = ["fileInput", "previews", "addTile"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    this.files = []
    this.useFor = []
  }

  filesSelected() {
    const incoming = Array.from(this.fileInputTarget.files || []).filter((file) => file.type.startsWith("image/"))
    const room = this.maxValue - this.files.length

    incoming.slice(0, room).forEach((file) => {
      this.files.push(file)
      this.useFor.push("overall")
    })

    this.#syncInput()
    this.#renderPreviews()
  }

  remove(event) {
    const index = Number(event.currentTarget.dataset.index)
    this.files.splice(index, 1)
    this.useFor.splice(index, 1)
    this.#syncInput()
    this.#renderPreviews()
  }

  updateUseFor(event) {
    const index = Number(event.target.dataset.index)
    this.useFor[index] = event.target.value
  }

  #syncInput() {
    const transfer = new DataTransfer()
    this.files.forEach((file) => transfer.items.add(file))
    this.fileInputTarget.files = transfer.files
    this.addTileTarget.classList.toggle("d-none", this.files.length >= this.maxValue)
  }

  // Renders one <select name="reference_use_for[]"> per thumbnail, in the same
  // order as the files -- this is what keeps each guidance choice positionally
  // aligned with its uploaded reference_images[] entry on submit.
  #renderPreviews() {
    this.previewsTarget.innerHTML = this.files
      .map(
        (file, index) => `
          <div class="reference-thumb">
            <img src="${URL.createObjectURL(file)}">
            <button type="button" class="reference-thumb-remove" data-action="reference-images#remove" data-index="${index}">
              <i class="fa-solid fa-xmark"></i>
            </button>
            <select name="reference_use_for[]" class="reference-use-for" data-index="${index}"
                    data-action="change->reference-images#updateUseFor">
              ${USE_FOR_OPTIONS.map(
                ([value, label]) => `<option value="${value}" ${this.useFor[index] === value ? "selected" : ""}>${label}</option>`
              ).join("")}
            </select>
          </div>
        `
      )
      .join("")
  }
}
