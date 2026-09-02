export const TIMINGS = {
  TEXT_DELAY: 2000,
  SCENE_DELAY: 2150,
  TEXT_MORPH_MS: 300,
  PROGRESS_MORPH_MS: 400,
  SCENE_TRANSITION_MS: 550,
  COLLAPSE_MS: 550,
  TEXT_EASING: "ease-out",
  SCENE_EASING: "ease-in-out",
  WORD_TRACK_EASING: "cubic-bezier(0.22, 1, 0.36, 1)",
  WORD_LINE_HEIGHT_PX: 72,
}

export const WORD_INDEX_BY_STEP = [0, 1, 2, 3, 0]

export const LOOP_WORDS = ["Tattoo", "Style", "Artist", "Client"]

export const SESSION_KEY = "kitatoo.homeIntroSeen"

export const LOOP_INDICES = [0, 1, 2, 3]

/** object-position values when hero is collapsed — adjust per photo */
export const IMAGE_COLLAPSED_POSITIONS = [
  "58% 30%",
  "center 25%",
  "center 35%",
  "center 20%",
  "center 30%",
]

export const IMAGE_FULL_POSITIONS = [
  "center center",
  "center center",
  "center center",
  "center center",
  "center center",
]

export const WORDS = ["Tattoo", "Style", "Artist", "Client", "Tattoo"]

/** @typedef {{ word: string, prompt: string, progress: number, showFooter: boolean }} HeroStep */

/** @type {HeroStep[]} */
export const STEPS = [
  {
    word: "Tattoo",
    prompt: "Discover the right tattoo design and aesthetics for your personal story.",
    progress: 1,
    showFooter: true,
  },
  {
    word: "Style",
    prompt: "Explore tattoo styles locally, or discover artists around the world.",
    progress: 2,
    showFooter: true,
  },
  {
    word: "Artist",
    prompt: "Connect with master ink specialists matching your target design genre.",
    progress: 3,
    showFooter: true,
  },
  {
    word: "Client",
    prompt: "Show the world your talent and grow your artist profile.",
    progress: 4,
    showFooter: true,
  },
  {
    word: "Tattoo",
    prompt: "",
    progress: 4,
    showFooter: false,
  },
]
