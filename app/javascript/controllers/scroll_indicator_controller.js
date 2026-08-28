import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scroller", "dot"]

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
