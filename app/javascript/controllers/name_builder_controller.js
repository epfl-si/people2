import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "firstSource", "lastSource",
    "firstInputField", "lastInputField",
    "firstInput", "lastInput",
    "explanationInput",
    "submitButton"
  ]

  static values = {
    firstSource: String,
    lastSource: String
  }

  connect() {
    this.firstWords = this.splitWords(this.firstSourceValue)
    this.lastWords = this.splitWords(this.lastSourceValue)

    this.selectedFirst = []
    this.selectedLast = []

    this.renderTags(this.firstWords, this.firstSourceTarget, this.toggleFirst.bind(this))
    this.renderTags(this.lastWords, this.lastSourceTarget, this.toggleLast.bind(this))
    this.updateUI()
  }

  splitWords(str) {
    return str.split(/\s+/).filter(w => w.length > 0)
  }

  renderTags(words, container, onClick) {
    container.innerHTML = ""
    words.forEach(word => {
      const tag = document.createElement("a")
      tag.href = "#"
      tag.className = "tag tag-primary badge bg-primary text-white"
      tag.textContent = word
      tag.addEventListener("click", event => {
        event.preventDefault()
        onClick(word)
      })
      container.appendChild(tag)
    })
  }

  toggleFirst(word) {
    this.toggleWord(word, this.selectedFirst)
    this.updateUI()
  }

  toggleLast(word) {
    this.toggleWord(word, this.selectedLast)
    this.updateUI()
  }

  toggleWord(word, list) {
    const index = list.indexOf(word)
    if (index >= 0) {
      list.splice(index, 1)
    } else {
      list.push(word)
    }
  }

  explanationChanged() {
    this.updateUI()
  }

  updateUI() {
    this.firstInputFieldTarget.innerHTML = ""
    this.selectedFirst.forEach(word => {
      this.firstInputFieldTarget.appendChild(this.createSelectedBadge(word, this.selectedFirst))
    })

    this.lastInputFieldTarget.innerHTML = ""
    this.selectedLast.forEach(word => {
      this.lastInputFieldTarget.appendChild(this.createSelectedBadge(word, this.selectedLast))
    })

    this.firstInputTarget.value = this.selectedFirst.join(" ")
    this.lastInputTarget.value = this.selectedLast.join(" ")

    const explanation = this.explanationInputTarget?.value?.trim()
    const valid = this.selectedFirst.length > 0 && this.selectedLast.length > 0 && explanation.length > 0

    this.submitButtonTarget.disabled = !valid
  }

  createSelectedBadge(word, list) {
    const span = document.createElement("span")
    span.className = "badge bg-danger text-white"
    span.textContent = word
    span.style.cursor = "pointer"
    span.addEventListener("click", () => {
      list.splice(list.indexOf(word), 1)
      this.updateUI()
    })
    return span
  }
}
