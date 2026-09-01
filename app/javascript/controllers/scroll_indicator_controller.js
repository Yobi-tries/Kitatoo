import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scroller", "dot"]

  connect() {
    const el = this.scrollerTarget
    let down = false
    let moved = false
    let startX = 0
    let startScroll = 0

    el.addEventListener("mousedown", (event) => {
      down = true
      moved = false
      startX = event.pageX
      startScroll = el.scrollLeft
      el.classList.add("is-dragging")
    })

    const release = () => {
      down = false
      el.classList.remove("is-dragging")
    }

    el.addEventListener("mouseup", release)
    el.addEventListener("mouseleave", release)

    el.addEventListener("mousemove", (event) => {
      if (!down) return

      const shift = event.pageX - startX
      if (Math.abs(shift) > 4) moved = true

      event.preventDefault()
      el.scrollLeft = startScroll - shift
    })

    el.addEventListener("dragstart", (event) => event.preventDefault())

    el.addEventListener("click", (event) => {
      if (!moved) return
      event.preventDefault()
      event.stopPropagation()
      moved = false
    }, true)
  }

  update() {
    const el = this.scrollerTarget
    const maxScroll = el.scrollWidth - el.clientWidth
    if (maxScroll <= 0) return

    const scrollRatio = el.scrollLeft / maxScroll
    const activeIndex = Math.min(
      Math.floor(scrollRatio * this.dotTargets.length),
      this.dotTargets.length - 1
    )

    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("home-scroll-dot--active", i === activeIndex)
    })
  }
}
