import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  checkShiftClick(event) {
    if (event.shiftKey) {
      const link = this.element.querySelector("a");
      if (link && link.href) {
        window.open(link.href, "_blank");
      }
    }
  }
}
