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
    this.pins = []
    this.clusters = []

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

      this.pins.push({ pin, lng: marker.lng, lat: marker.lat })

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

    this.map.on("moveend", () => this.#groupPins())
    this.#groupPins()
  }

  #groupPins() {
    this.clusters.forEach((cluster) => cluster.remove())
    this.clusters = []
    this.pins.forEach(({ pin }) => { pin.getElement().style.display = "" })

    const grouped = new Set()

    this.pins.forEach((current, index) => {
      if (grouped.has(index)) return

      const origin = this.map.project([ current.lng, current.lat ])
      const near = [ index ]

      this.pins.forEach((other, position) => {
        if (position <= index || grouped.has(position)) return

        const point = this.map.project([ other.lng, other.lat ])
        if (Math.hypot(origin.x - point.x, origin.y - point.y) < 44) near.push(position)
      })

      if (near.length < 2) return

      near.forEach((position) => {
        grouped.add(position)
        this.pins[position].pin.getElement().style.display = "none"
      })

      this.clusters.push(this.#buildCluster(current, near.length))
    })
  }

  #buildCluster(anchor, count) {
    const element = document.createElement("button")
    element.type = "button"
    element.className = "map-cluster"
    element.textContent = count
    element.setAttribute("aria-label", `${count} studios here, zoom in`)

    element.addEventListener("click", () => {
      this.map.easeTo({ center: [ anchor.lng, anchor.lat ], zoom: this.map.getZoom() + 3 })
    })

    return new mapboxgl.Marker({ element })
      .setLngLat([ anchor.lng, anchor.lat ])
      .addTo(this.map)
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
      const locations = JSON.parse(card.dataset.locations)
      const inside = !bounds || locations.some((location) => bounds.contains(location))
      ;(inside ? inZone : outZone).push(card)
    })

    const visibleCards = inZone.slice(0, this.visibleCount)

    this.orderedCards.forEach((card) => { card.hidden = true })
    visibleCards.forEach((card) => { card.hidden = false })

    this.listTarget.append(...inZone, ...outZone)

    if (this.hasCountTarget) {
      this.countTarget.textContent = inZone.length
    }

    if (this.hasMoreTarget) {
      this.moreTarget.hidden = inZone.length <= this.visibleCount
    }
  }
}
