import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

export default class extends Controller {
  static targets = ["canvas", "card", "count", "list", "listButton", "mapButton", "more", "notice"]
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
      this.orderedCards = [ ...this.cardTargets ]
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

    this.filtering = false
    this.visibleCount = 5
    this.#renderCards()
  }

  #switchTo(on, off) {
    on.classList.add("view-switch-option--active")
    off.classList.remove("view-switch-option--active")
  }

  #addMarkersToMap() {
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup({ offset: 24, closeButton: false })
        .setHTML(`
          <a class="map-popup" href="${marker.url}">
            <img class="map-popup-avatar" src="${marker.avatar}" alt="">
            <span class="map-popup-body">
              <span class="map-popup-name">${marker.name}</span>
              <span class="map-popup-city">${marker.city}${marker.distance ? ` &middot; ${marker.distance} km` : ""}</span>
            </span>
          </a>
        `)

      const pin = new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(popup)
        .addTo(this.map)

      let timer

      const open = () => {
        clearTimeout(timer)
        if (!popup.isOpen()) popup.addTo(this.map)
      }

      const close = () => {
        timer = setTimeout(() => popup.remove(), 120)
      }

      pin.getElement().addEventListener("mouseenter", open)
      pin.getElement().addEventListener("mouseleave", close)

      popup.on("open", () => {
        popup.getElement().addEventListener("mouseenter", open)
        popup.getElement().addEventListener("mouseleave", close)
      })
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
    const inZone = []
    const outZone = []

    this.orderedCards.forEach((card) => {
      const inside = !bounds || bounds.contains([ Number(card.dataset.lng), Number(card.dataset.lat) ])
      ;(inside ? inZone : outZone).push(card)
    })

    const nearby = inZone.slice(0, this.visibleCount)
    const missing = this.visibleCount - nearby.length
    const fallback = missing > 0 ? outZone.slice(0, missing) : []

    this.orderedCards.forEach((card) => { card.hidden = true })
    nearby.concat(fallback).forEach((card) => { card.hidden = false })

    this.listTarget.append(...nearby)
    if (this.hasNoticeTarget) this.listTarget.append(this.noticeTarget)
    this.listTarget.append(...fallback, ...outZone.slice(missing > 0 ? missing : 0), ...inZone.slice(this.visibleCount))

    if (this.hasNoticeTarget) {
      this.noticeTarget.hidden = fallback.length === 0
    }

    if (this.hasCountTarget) {
      this.countTarget.textContent = inZone.length
    }

    if (this.hasMoreTarget) {
      this.moreTarget.hidden = this.orderedCards.length <= this.visibleCount
    }
  }
}
