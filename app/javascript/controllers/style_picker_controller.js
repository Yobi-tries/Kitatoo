import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pill"]
  static values = { max: { type: Number, default: 2 } }

  toggle(event) {
    const pill = event.currentTarget

    if (pill.classList.contains("disabled")) return

    if (this.#isSelected(pill)) {
      this.#deselect(pill)
    } else if (this.#selectedCount() < this.maxValue) {
      this.#select(pill)
    }

    this.#refreshAvailability()
  }

  #isSelected(pill) {
    return pill.classList.contains("text-bg-dark")
  }

  #select(pill) {
    pill.classList.remove("text-bg-light", "border")
    pill.classList.add("text-bg-dark")

    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "style_tag_ids[]"
    input.value = pill.dataset.tagId
    input.dataset.stylePickerTarget = "input"
    pill.appendChild(input)
  }

  #deselect(pill) {
    pill.classList.remove("text-bg-dark")
    pill.classList.add("text-bg-light", "border")
    pill.querySelector("input[type=hidden]")?.remove()
  }

  #selectedCount() {
    return this.pillTargets.filter((pill) => this.#isSelected(pill)).length
  }

  #refreshAvailability() {
    const full = this.#selectedCount() >= this.maxValue
    this.pillTargets.forEach((pill) => {
      pill.classList.toggle("disabled", full && !this.#isSelected(pill))
    })
  }
}
