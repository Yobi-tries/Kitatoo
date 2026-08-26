import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "row"]

  add() {
    const index = this.rowTargets.length
    const row = document.createElement("div")
    row.classList.add("row", "mb-2", "align-items-center")
    row.setAttribute("data-pricing-target", "row")
    row.innerHTML = `
      <div class="col-6">
        <input type="text" name="artist_profile[pricing_grid][${index}][prestation]"
               class="form-control" placeholder="Service">
      </div>
      <div class="col-4">
        <div class="input-group">
          <input type="number" name="artist_profile[pricing_grid][${index}][prix]"
                 class="form-control" placeholder="Price" step="0.01" min="0">
          <span class="input-group-text">€</span>
        </div>
      </div>
      <div class="col-2">
        <button type="button" class="btn btn-outline-danger btn-sm" data-action="pricing#remove">✕</button>
      </div>
    `
    this.listTarget.appendChild(row)
  }

  remove(event) {
    event.currentTarget.closest("[data-pricing-target='row']").remove()
  }
}
