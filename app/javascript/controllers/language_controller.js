// app/javascript/controllers/language_controller.js
// The UI for this have been rejected but I keep it in the code
// for future reference and because I think it was a nice idea.
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