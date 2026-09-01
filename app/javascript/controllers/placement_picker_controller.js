import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["otherInput", "extraCard", "moreToggle"]

  connect() {
    if (this.extraCardTargets.some((card) => card.classList.contains("is-visible"))) {
      this.showMore()
    }
  }

  showMore() {
    this.extraCardTargets.forEach((card) => card.classList.add("is-visible"))
    this.moreToggleTarget.classList.add("d-none")
  }

  toggleOther(event) {
    const isOther = event.currentTarget.dataset.isOther === "true"
    this.otherInputTarget.classList.toggle("d-none", !isOther)
    this.otherInputTarget.required = isOther
    if (!isOther) this.otherInputTarget.value = ""
  }
}
