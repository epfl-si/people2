// app/javascript/controllers/language_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { full: String, active: String, inactive: String };
  static targets = [ "button" ];

  setEnabledLanguage(event) {
    this.buttonTargets.forEach( t => t.classList=this.inactiveValue );
    event.target.classList=this.activeValue;
    this.element.classList=event.target.dataset.langcls;
  }
}