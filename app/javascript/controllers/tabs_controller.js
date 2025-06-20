import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]
  static values = { index: Number }

  connect() {
  console.log("[tabs] connected", this.tabTargets.length, this.contentTargets.length)
    this.indexValue = this.indexValue || 0
    this.showActivePanel()
    this.adjustMinHeight()
  }

  change(event) {
    event.preventDefault()

    const selected = event.currentTarget.dataset.tabName
    const scrollX = window.scrollX
    const scrollY = window.scrollY
    const activeElement = document.activeElement

    this.tabTargets.forEach(tab => {
      tab.classList.toggle("active", tab.dataset.tabName === selected)
    })

    this.contentTargets.forEach(content => {
      const isActive = content.dataset.tabName === selected
      content.classList.toggle("active", isActive)
      content.classList.toggle("show", isActive)
    })

    window.scrollTo(scrollX, scrollY)
    if (activeElement) activeElement.blur()
  }

  showActivePanel() {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("active", i === this.indexValue)
    })

    this.contentTargets.forEach((content, i) => {
      const isActive = i === this.indexValue
      content.classList.toggle("active", isActive)
      content.classList.toggle("show", isActive)
    })
  }

  adjustMinHeight() {
    let maxHeight = 0
    this.contentTargets.forEach(el => {
      const wasHidden = el.classList.contains("d-none")
      if (wasHidden) el.classList.remove("d-none")
      const height = el.offsetHeight
      if (wasHidden) el.classList.add("d-none")
      if (height > maxHeight) maxHeight = height
    })

    const container = this.element.querySelector(".tab-content")
    if (container) {
      container.style.minHeight = `${maxHeight}px`
    }
  }
}
