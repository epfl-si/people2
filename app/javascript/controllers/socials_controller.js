import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["urlPreview", "valueField"];
  static values = { pattern: String };

  url() {
    const value = this.valueFieldTarget.value.trim();
    return value ? this.patternValue.replace("XXX", value) : null;
  }

  onValueChange() {
    console.log("onValueChange");
    const url = this.url();
    this.urlPreviewTarget.textContent = url;
    this.urlPreviewTarget.href = url;
  }
}
