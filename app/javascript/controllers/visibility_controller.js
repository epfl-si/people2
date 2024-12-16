// app/javascript/controllers/visibility_controller.js
import { Controller } from "@hotwired/stimulus"
import { put } from "@rails/request.js";

export default class extends Controller {
  static values = { model: String };
  static targets = [ "radio" ];

  connect() {
    this.oldRadio = this.radioTargets.find((x) => x.checked);
    this.recovering = false;
  }

  onChange() {
    if (this.recovering) {
      console.log("Recovering");
      this.recovering = false;
      return;
    }

    const newRadio = this.radioTargets.find((x) => x.checked);
    const value = newRadio.value;
    const url = this.element.action;
    // JS shit!
    const body = {};
    body[this.modelValue] = {'audience': value};
    put(url, {body: body}).then((response) => {
      if (response.ok) {
        this.oldRadio = newRadio;
      } else {
        // TODO: add flash message on error
        // prevent onChange to fire again
        this.recovering = true;
        this.oldRadio.click();
      }
    });
  }
}