import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pills", "pill", "input", "dropdown"]
  static values = { available: Array }

  connect() {
    this.activeIndex = -1
  }

  onFocus() {
    this.renderOptions(this.inputTarget.value)
  }

  onInput() {
    this.renderOptions(this.inputTarget.value)
  }

  moveDown(event) {
    if (this.dropdownTarget.classList.contains("d-none")) return
    event.preventDefault()
    this.setActiveIndex(this.activeIndex + 1)
  }

  moveUp(event) {
    if (this.dropdownTarget.classList.contains("d-none")) return
    event.preventDefault()
    this.setActiveIndex(this.activeIndex - 1)
  }

  commit(event) {
    event.preventDefault()

    const options = this.currentOptionElements()
    if (this.activeIndex >= 0 && options[this.activeIndex]) {
      this.commitTag(options[this.activeIndex].dataset.value)
      return
    }

    const query = this.inputTarget.value.trim()
    if (!query) return

    this.commitTag(query)
  }

  selectOption(event) {
    this.commitTag(event.currentTarget.dataset.value)
  }

  closeDropdown() {
    this.dropdownTarget.classList.add("d-none")
    this.dropdownTarget.replaceChildren()
    this.activeIndex = -1
  }

  outsideClick(event) {
    if (!this.element.contains(event.target)) this.closeDropdown()
  }

  remove(event) {
    event.currentTarget.closest("[data-tags-target='pill']").remove()
  }

  // --- internals ---

  renderOptions(query) {
    const trimmed = query.trim()
    const addedNames = this.pillTargets.map((pill) => pill.dataset.name)
    const candidates = this.availableValue.filter((name) => !addedNames.includes(name.toLowerCase()))

    let matches = candidates
    let exactMatch = null

    if (trimmed) {
      const lower = trimmed.toLowerCase()
      matches = candidates.filter((name) => name.toLowerCase().includes(lower))
      exactMatch = candidates.find((name) => name.toLowerCase() === lower)
    }

    this.dropdownTarget.replaceChildren()
    this.activeIndex = -1

    const heading = document.createElement("div")
    heading.className = "tags-dropdown-heading"
    heading.textContent = trimmed ? "Matching styles" : "Suggested styles"

    let hasContent = false

    if (matches.length > 0) {
      hasContent = true
      this.dropdownTarget.appendChild(heading)
      matches.forEach((name) => this.dropdownTarget.appendChild(this.buildOption(name, name)))
    }

    if (trimmed && !exactMatch) {
      hasContent = true
      const addLabel = `+ Add "${trimmed}"`
      this.dropdownTarget.appendChild(this.buildOption(addLabel, trimmed, true))
    }

    if (!hasContent) {
      this.dropdownTarget.classList.add("d-none")
      return
    }

    this.dropdownTarget.classList.remove("d-none")
  }

  buildOption(label, value, isCreate = false) {
    const option = document.createElement("button")
    option.type = "button"
    option.className = "tags-dropdown-option" + (isCreate ? " tags-dropdown-option-create" : "")
    option.dataset.value = value
    option.setAttribute("role", "option")
    option.setAttribute("data-action", "tags#selectOption")
    option.textContent = label
    return option
  }

  currentOptionElements() {
    return Array.from(this.dropdownTarget.querySelectorAll(".tags-dropdown-option"))
  }

  setActiveIndex(index) {
    const options = this.currentOptionElements()
    if (options.length === 0) return

    this.activeIndex = (index + options.length) % options.length

    options.forEach((option, i) => {
      option.classList.toggle("is-active", i === this.activeIndex)
    })
    options[this.activeIndex].scrollIntoView({ block: "nearest" })
  }

  commitTag(name) {
    const trimmed = name.trim()
    if (!trimmed) return

    const alreadyAdded = this.pillTargets.some((pill) => pill.dataset.name === trimmed.toLowerCase())
    if (!alreadyAdded) {
      // An existing tag always keeps its canonical casing; only a brand-new
      // tag gets capitalized here (mirrors Tag.capitalized server-side).
      const canonical = this.availableValue.find((available) => available.toLowerCase() === trimmed.toLowerCase())
      this.addPill(canonical || this.capitalizeWords(trimmed))
    }

    this.inputTarget.value = ""
    this.closeDropdown()
    this.inputTarget.focus()
  }

  capitalizeWords(name) {
    return name.toLowerCase().replace(/\b\w/g, (char) => char.toUpperCase())
  }

  addPill(name) {
    const pill = document.createElement("span")
    pill.className = "badge rounded-pill text-bg-dark d-inline-flex align-items-center gap-2 py-2 px-3"
    pill.dataset.tagsTarget = "pill"
    pill.dataset.name = name.toLowerCase()

    const label = document.createElement("span")
    label.textContent = name
    pill.appendChild(label)

    const hidden = document.createElement("input")
    hidden.type = "hidden"
    hidden.name = "artist_profile[tag_names][]"
    hidden.value = name
    pill.appendChild(hidden)

    const removeBtn = document.createElement("button")
    removeBtn.type = "button"
    removeBtn.className = "btn-close btn-close-white"
    removeBtn.style.fontSize = "0.55rem"
    removeBtn.setAttribute("aria-label", "Remove")
    removeBtn.setAttribute("data-action", "tags#remove")
    pill.appendChild(removeBtn)

    this.pillsTarget.appendChild(pill)
  }
}
