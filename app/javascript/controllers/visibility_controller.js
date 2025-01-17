// app/javascript/controllers/visibility_controller.js
import { Controller } from "@hotwired/stimulus"
import { put } from "@rails/request.js";

export default class extends Controller {
  static values = { model: String, field: String };
  static targets = [ "form", "radio", "label"];

  connect() {
    this.oldRadio = this.radioTargets.find((x) => x.checked);
    this.url = this.formTarget.action;
    this.recovering = false;
  }

  onChange() {
    if (this.recovering) {
      this.recovering = false;
      return;
    }

    const newRadio = this.radioTargets.find((x) => x.checked);

    const value = newRadio.value;
    const label = newRadio.getAttribute('data-label');
    // JS shit!
    const body = {};
    body[this.modelValue] = {};
    body[this.modelValue][this.fieldValue] = value;
    put(this.url, {body: body}).then((response) => {
      if (response.ok) {
        this.oldRadio = newRadio;
        this.labelTarget.textContent=label;
      } else {
        // TODO: add flash message on error
        // prevent onChange to fire again
        this.recovering = true;
        this.oldRadio.click();
      }
    });
  }
}