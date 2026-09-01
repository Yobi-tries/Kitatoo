import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pill", "selected", "unselected"]
  static values = { max: { type: Number, default: 2 }, preselected: Array }

  connect() {
    this.preselectedValue.forEach((id) => {
      const pill = this.pillTargets.find((p) => p.dataset.tagId === String(id))
      if (pill) this.#select(pill)
    })
    this.#refreshAvailability()
  }

  toggle(event) {
    const pill = event.currentTarget
    if (pill.dataset.selected === "true") {
      this.#deselect(pill)
    } else if (this.#selectedCount() < this.maxValue) {
      this.#select(pill)
    }
    this.#refreshAvailability()
  }

  #select(pill) {
    pill.dataset.selected = "true"
    pill.className = "style-tile style-picker-card"
    const img = pill.dataset.tagImage
    pill.innerHTML = `
      ${img ? `<img src="${img}" class="style-tile-image" alt="">` : ""}
      <span class="style-tile-name">${pill.dataset.tagName}</span>
      <i class="fa-solid fa-circle-check style-picker-check"></i>
      <input type="hidden" name="style_tag_ids[]" value="${pill.dataset.tagId}">
    `
    this.selectedTarget.appendChild(pill)
  }

  #deselect(pill) {
    pill.dataset.selected = "false"
    pill.className = "badge rounded-pill text-bg-light border style-pill"
    pill.innerHTML = pill.dataset.tagName
    this.unselectedTarget.appendChild(pill)
  }

  #selectedCount() {
    return this.pillTargets.filter((p) => p.dataset.selected === "true").length
  }

  #refreshAvailability() {
    const full = this.#selectedCount() >= this.maxValue
    this.pillTargets.forEach((p) => {
      if (p.dataset.selected !== "true") p.classList.toggle("disabled", full)
    })
  }
}
