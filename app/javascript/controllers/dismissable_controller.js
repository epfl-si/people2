import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // static values = { model: String, field: String };
  static targets = ["content"];

  connect() {
    console.log("dismissable controller connected");
  }

  dismiss() {
    this.contentTarget.innerHTML = "";
    // eventually remove the editor-overlay too
    const overlay = document.getElementById("editor-overlay")
    if (overlay) overlay.innerHTML = "";
  }
}
