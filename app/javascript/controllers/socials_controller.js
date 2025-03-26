import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlPreview", "valueField", "checkButton"];
  static values = { pattern: String }

  url() {
    const value = this.valueFieldTarget.value.trim();
    return value ? this.patternValue.replace("XXX", value) : null
  }

  onValueChange() {
    const url = this.url();
    this.urlPreviewTarget.textContent = url;
    if(url) {
      this.checkButtonTarget.disabled = false;
    } else {
      this.checkButtonTarget.disabled = true;
    }
  }

  checkLink() {
    const url = this.url();
    if(url) {
      window.open(this.url(), '_blank');
    }
  }
}
