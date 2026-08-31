import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

export default class extends Controller {
  static targets = ["canvas", "card", "count", "list", "listButton", "mapButton", "more"]
  static values = {
    apiKey: String,
    markers: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.hasCanvasTarget ? this.canvasTarget : this.element,
      style: "mapbox://styles/mapbox/streets-v12"
    })

    this.#addMarkersToMap()

    if (!this.hasCanvasTarget || !this.canvasTarget.hidden) {
      this.#fitMapToMarkers()
    }

    if (this.hasCardTarget) {
      this.visibleCount = 5
      this.filtering = false
      this.#renderCards()

      this.map.on("moveend", () => {
        if (this.canvasTarget.hidden) return

        this.filtering = true
        this.visibleCount = 5
        this.#renderCards()
      })
    }
  }

  showMap() {
    this.canvasTarget.hidden = false
    this.listTarget.hidden = false
    this.#switchTo(this.mapButtonTarget, this.listButtonTarget)

    const top = this.canvasTarget.getBoundingClientRect().top
    this.canvasTarget.style.height = `${window.innerHeight - top - 84}px`

    this.map.resize()
    this.#fitMapToMarkers()
  }

  showList() {
    this.canvasTarget.hidden = true
    this.listTarget.hidden = false
    this.#switchTo(this.listButtonTarget, this.mapButtonTarget)
  }

  #switchTo(on, off) {
    on.classList.add("view-switch-option--active")
    off.classList.remove("view-switch-option--active")
  }

  #addMarkersToMap() {
    this.markersValue.forEach((marker) => {
      new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .addTo(this.map)
    })
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 30, maxZoom: 15, duration: 0 })
  }

  showMore() {
    this.visibleCount += 5
    this.#renderCards()
  }

  #renderCards() {
    const bounds = this.filtering ? this.map.getBounds() : null
    let matched = 0

    this.cardTargets.forEach((card) => {
      const inside = !bounds || bounds.contains([ Number(card.dataset.lng), Number(card.dataset.lat) ])

      if (inside) {
        matched += 1
        card.hidden = matched > this.visibleCount
      } else {
        card.hidden = true
      }
    })

    if (this.hasCountTarget) {
      this.countTarget.textContent = matched
    }

    if (this.hasMoreTarget) {
      this.moreTarget.hidden = matched <= this.visibleCount
    }
  }
}
