import { Controller } from "@hotwired/stimulus"
import StepEngine, { TIMINGS, STEPS } from "find_your_hero/step_engine"
import {
  SESSION_KEY,
  IMAGE_COLLAPSED_POSITIONS,
  IMAGE_FULL_POSITIONS,
  WORD_INDEX_BY_STEP,
} from "find_your_hero/constants"

export default class extends Controller {
  static targets = [
    "image",
    "wordTrack",
    "footer",
    "counterCurrent",
    "progress",
    "prompt",
  ]

  connect() {
    this.topappbar = document.querySelector(".topappbar")
    this.botappbar = document.querySelector(".botappbar")
    this.topappbar?.classList.add("topappbar--home-hero")
    this.currentWordIndex = 0
    this.introSeen = sessionStorage.getItem(SESSION_KEY) === "1"
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches

    this.engine = new StepEngine({
      onTextMorph: (index) => this.morphToStep(index),
      onSceneTransition: (index) => this.transitionScene(index),
      onCollapse: () => this.collapse(),
    })

    this.setupHeroVisibilityObserver()

    if (this.reducedMotion || this.introSeen) {
      this.enterCollapsedState()
      return
    }

    this.hideBotappbar()
    this.startIntro()
  }

  disconnect() {
    this.engine?.clearAllTimers()
    this.heroObserver?.disconnect()
    document.body.style.overflow = ""
    this.topappbar?.classList.remove("topappbar--home-hero", "topappbar--hero-intro", "topappbar--past-hero")
  }

  setupHeroVisibilityObserver() {
    this.heroObserver = new IntersectionObserver(
      ([entry]) => {
        this.topappbar?.classList.toggle("topappbar--past-hero", !entry.isIntersecting)
      },
      { threshold: 0, rootMargin: "-64px 0px 0px 0px" }
    )
    this.heroObserver.observe(this.element)
  }

  hideBotappbar() {
    if (this.botappbar) this.botappbar.hidden = true
  }

  showBotappbar() {
    if (this.botappbar) this.botappbar.hidden = false
  }

  isCollapsed() {
    return this.element.classList.contains("find-your-hero--collapsed")
  }

  isCollapsedOrCollapsing() {
    return this.isCollapsed() ||
      this.element.classList.contains("find-your-hero--collapsing")
  }

  /** @param {number} wordIndex @param {{ animate?: boolean }} options */
  setWordIndex(wordIndex, { animate = true } = {}) {
    const track = this.wordTrackTarget
    const offset = wordIndex * TIMINGS.WORD_LINE_HEIGHT_PX
    const wrapping = this.currentWordIndex === 3 && wordIndex === 0

    if (!animate || this.reducedMotion || wrapping) {
      track.classList.add("find-your-hero__word-track--no-transition")
    }

    track.style.transform = `translate3d(0, -${offset}px, 0)`

    if (!animate || this.reducedMotion || wrapping) {
      void track.offsetHeight
      track.classList.remove("find-your-hero__word-track--no-transition")
    }

    this.currentWordIndex = wordIndex
  }

  applyImagePositions() {
    const collapsed = this.isCollapsedOrCollapsing()
    this.imageTargets.forEach((image, index) => {
      const position = collapsed
        ? (image.dataset.collapsedPosition || IMAGE_COLLAPSED_POSITIONS[index] || "center center")
        : (image.dataset.fullPosition || IMAGE_FULL_POSITIONS[index] || "center center")
      image.style.objectPosition = position
    })
  }

  startIntro() {
    this.element.classList.remove("find-your-hero--collapsed")
    this.element.classList.add("find-your-hero--intro")
    this.topappbar?.classList.add("topappbar--hero-intro")
    document.body.style.overflow = "hidden"
    this.setWordIndex(0, { animate: false })
    this.applyImagePositions()
    this.transitionScene(0)
    this.engine.start()
  }

  enterCollapsedState() {
    this.element.classList.remove("find-your-hero--intro", "find-your-hero--collapsing")
    this.element.classList.add("find-your-hero--collapsed")
    this.footerTarget.hidden = true
    this.setWordIndex(0, { animate: false })
    this.applyImagePositions()
    this.transitionScene(0)
    this.showBotappbar()
    this.engine.startLoop(0)
  }

  /** @param {number} index */
  morphToStep(index) {
    const step = STEPS[index]
    if (!step) return

    const wordIndex = WORD_INDEX_BY_STEP[index] ?? 0
    if (wordIndex === this.currentWordIndex) return

    const track = this.wordTrackTarget
    track.style.transitionDuration = `${TIMINGS.TEXT_MORPH_MS}ms`
    track.style.transitionTimingFunction = TIMINGS.WORD_TRACK_EASING
    this.setWordIndex(wordIndex)

    if (!this.isCollapsed()) {
      const progressPercent = (step.progress / 4) * 100
      this.counterCurrentTarget.textContent = String(step.progress).padStart(2, "0")
      this.progressTarget.style.transitionDuration = `${TIMINGS.PROGRESS_MORPH_MS}ms`
      this.progressTarget.style.transitionTimingFunction = TIMINGS.TEXT_EASING
      this.progressTarget.style.width = `${progressPercent}%`
    }
  }

  /** @param {number} index */
  transitionScene(index) {
    const step = STEPS[index]
    if (!step) return

    this.element.classList.add("find-your-hero--scene-transition")

    this.imageTargets.forEach((image, imageIndex) => {
      image.classList.toggle("is-active", imageIndex === index)
    })

    this.applyImagePositions()

    if (!this.isCollapsed() && step.showFooter) {
      this.footerTarget.hidden = false
      this.promptTarget.textContent = step.prompt
      this.counterCurrentTarget.textContent = String(step.progress).padStart(2, "0")
      this.progressTarget.style.transitionDuration = `${TIMINGS.PROGRESS_MORPH_MS}ms`
      this.progressTarget.style.width = `${(step.progress / 4) * 100}%`
    } else {
      this.footerTarget.hidden = true
    }

    window.setTimeout(() => {
      this.element.classList.remove("find-your-hero--scene-transition")
    }, TIMINGS.SCENE_TRANSITION_MS)
  }

  collapse() {
    this.engine.clearAllTimers()
    this.footerTarget.hidden = true
    this.topappbar?.classList.remove("topappbar--hero-intro")

    this.element.classList.remove("find-your-hero--intro")
    this.element.classList.add("find-your-hero--collapsing")

    requestAnimationFrame(() => {
      this.applyImagePositions()
      this.element.classList.add("find-your-hero--collapse-active")
    })

    window.setTimeout(() => {
      this.element.classList.remove("find-your-hero--collapsing", "find-your-hero--collapse-active")
      this.element.classList.add("find-your-hero--collapsed")
      this.applyImagePositions()
      document.body.style.overflow = ""
      sessionStorage.setItem(SESSION_KEY, "1")
      window.scrollTo({ top: 0, behavior: "instant" })
      this.showBotappbar()
      this.engine.startLoop(4)
    }, TIMINGS.COLLAPSE_MS)
  }
}
