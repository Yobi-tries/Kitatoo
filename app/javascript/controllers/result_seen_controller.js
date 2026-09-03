import { Controller } from "@hotwired/stimulus"

// Marks a Tattoo Generator result (TattooGeneration or BodyPreview) as
// viewed once its card is open, the result is completed, and the tab is
// visible -- whether the card was just opened or the result just streamed
// in while already open. Reacts to the content target's `hidden` attribute
// rather than to specific open actions, so it stays decoupled from
// collapsible-card and body-preview-source.
export default class extends Controller {
  static targets = ["content", "result"]

  connect() {
    this.observer = new MutationObserver(() => this.#evaluate())
    if (this.hasContentTarget) {
      this.observer.observe(this.contentTarget, { attributes: true, attributeFilter: [ "hidden" ] })
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }

  resultTargetConnected() {
    this.#evaluate()
  }

  #evaluate() {
    if (!this.hasContentTarget || !this.hasResultTarget) return
    if (this.contentTarget.hidden) return
    if (document.visibilityState !== "visible") return
    if (this.resultTarget.dataset.completed !== "true") return

    const url = this.resultTarget.dataset.markViewedUrl
    if (!url) return

    fetch(url, {
      method: "PATCH",
      headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content }
    })
  }
}
