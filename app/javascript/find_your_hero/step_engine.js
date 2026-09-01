import { TIMINGS, STEPS, LOOP_INDICES } from "find_your_hero/constants"

/**
 * Dual-clock step engine for the Find Your hero intro.
 * Clock A: text morph + progress (TEXT_DELAY → TEXT_MORPH_MS)
 * Clock B: scene transition (SCENE_DELAY → SCENE_TRANSITION_MS)
 */
export default class StepEngine {
  /**
   * @param {object} callbacks
   * @param {(nextStepIndex: number) => void} callbacks.onTextMorph
   * @param {(nextStepIndex: number) => void} callbacks.onSceneTransition
   * @param {() => void} callbacks.onCollapse
   */
  constructor({ onTextMorph, onSceneTransition, onCollapse }) {
    this.onTextMorph = onTextMorph
    this.onSceneTransition = onSceneTransition
    this.onCollapse = onCollapse
    this.timers = []
    this.stepIndex = 0
    this.loopIndex = 0
    this.running = false
    this.mode = null
  }

  start() {
    this.mode = "intro"
    this.running = true
    this.stepIndex = 0
    this.scheduleStepCycle(0)
  }

  /** @param {number} currentStepIndex */
  startLoop(currentStepIndex = 0) {
    this.mode = "loop"
    this.running = true
    this.loopIndex = LOOP_INDICES.indexOf(currentStepIndex)
    if (this.loopIndex === -1) this.loopIndex = 0
    this.scheduleLoopCycle()
  }

  /**
   * @param {number} index
   */
  scheduleStepCycle(index) {
    const step = STEPS[index]
    if (!step) return

    if (index === STEPS.length - 1) {
      this.scheduleTimer(() => this.onCollapse(), TIMINGS.SCENE_DELAY + TIMINGS.SCENE_TRANSITION_MS)
      return
    }

    const nextIndex = index + 1

    this.scheduleTimer(() => {
      if (!this.running || this.mode !== "intro") return
      this.onTextMorph(nextIndex)
    }, TIMINGS.TEXT_DELAY)

    this.scheduleTimer(() => {
      if (!this.running || this.mode !== "intro") return
      this.onSceneTransition(nextIndex)
      this.stepIndex = nextIndex
      this.scheduleTimer(() => {
        if (!this.running || this.mode !== "intro") return
        this.scheduleStepCycle(nextIndex)
      }, TIMINGS.SCENE_TRANSITION_MS)
    }, TIMINGS.SCENE_DELAY)
  }

  scheduleLoopCycle() {
    const nextLoopIndex = (this.loopIndex + 1) % LOOP_INDICES.length
    const nextStepIndex = LOOP_INDICES[nextLoopIndex]

    this.scheduleTimer(() => {
      if (!this.running || this.mode !== "loop") return
      this.onTextMorph(nextStepIndex)
    }, TIMINGS.TEXT_DELAY)

    this.scheduleTimer(() => {
      if (!this.running || this.mode !== "loop") return
      this.onSceneTransition(nextStepIndex)
      this.loopIndex = nextLoopIndex
      this.scheduleTimer(() => {
        if (!this.running || this.mode !== "loop") return
        this.scheduleLoopCycle()
      }, TIMINGS.SCENE_TRANSITION_MS)
    }, TIMINGS.SCENE_DELAY)
  }

  /**
   * @param {Function} callback
   * @param {number} delay
   */
  scheduleTimer(callback, delay) {
    const id = window.setTimeout(callback, delay)
    this.timers.push(id)
  }

  clearAllTimers() {
    this.timers.forEach((id) => window.clearTimeout(id))
    this.timers = []
    this.running = false
    this.mode = null
  }
}

export { TIMINGS, STEPS }
