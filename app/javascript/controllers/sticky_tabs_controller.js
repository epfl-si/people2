import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabs"]

  connect() {
    this.handleScroll = this.checkSticky.bind(this)
    window.addEventListener("scroll", this.handleScroll)
    this.checkSticky()
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  checkSticky() {
    const tabs = this.tabsTarget
    const stickyTop = tabs.getBoundingClientRect().top

    if (stickyTop <= 0) {
      tabs.classList.add("is-stuck")
    } else {
      tabs.classList.remove("is-stuck")
    }
  }
}
