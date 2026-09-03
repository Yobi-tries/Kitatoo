import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pill", "selected", "unselected", "moreButton"]
  static values = { max: { type: Number, default: 1 }, preselected: Array, visibleCount: { type: Number, default: 3 } }

  connect() {
    this.expanded = false
    this.#collapse()

    this.preselectedValue.forEach((id) => {
      const pill = this.pillTargets.find((p) => p.dataset.tagId === String(id))
      if (pill) this.#select(pill)
    })
  }

  toggle(event) {
    const pill = event.currentTarget
    if (pill.dataset.selected === "true") {
      this.#deselect(pill)
    } else {
      while (this.#selectedCount() >= this.maxValue) {
        const previous = this.pillTargets.find((p) => p.dataset.selected === "true")
        if (!previous) break
        this.#deselect(previous)
      }
      this.#select(pill)
    }
  }

  expand() {
    this.expanded = true
    this.#showAll()
    if (this.hasMoreButtonTarget) this.moreButtonTarget.hidden = true
  }

  #collapse() {
    const unselected = this.pillTargets.filter((p) => p.dataset.selected === "false")
    unselected.forEach((pill, i) => {
      pill.hidden = i >= this.visibleCountValue
    })
    if (this.hasMoreButtonTarget) {
      this.moreButtonTarget.hidden = unselected.length <= this.visibleCountValue
    }
  }

  #showAll() {
    this.pillTargets.forEach((pill) => { pill.hidden = false })
  }

  #select(pill) {
    pill.dataset.selected = "true"
    pill.hidden = false
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
    if (!this.expanded) this.#collapse()
  }

  #selectedCount() {
    return this.pillTargets.filter((p) => p.dataset.selected === "true").length
  }
}
