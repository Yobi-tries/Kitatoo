import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "row"]

  add() {
    const row = document.createElement("div")
    row.classList.add("row", "mb-2", "align-items-center")
    row.setAttribute("data-tags-target", "row")
    row.innerHTML = `
      <div class="col-10">
        <input type="text" name="artist_profile[tag_names][]"
               class="form-control" list="tags_datalist" placeholder="e.g. Blackwork" autocomplete="off">
      </div>
      <div class="col-2">
        <button type="button" class="btn btn-outline-danger btn-sm" data-action="tags#remove">✕</button>
      </div>
    `
    this.listTarget.appendChild(row)
  }

  remove(event) {
    event.currentTarget.closest("[data-tags-target='row']").remove()
  }
}
