// app/javascript/controllers/box_visibility_controller.js
import { Controller } from "@hotwired/stimulus"
import { put } from "@rails/request.js";
    
export default class extends Controller {
  static values = { url: String };
  static targets = [ "checkbox", "label" ];

  connect() {
    console.log("box_vixibility_controller connect");
    console.log(this.element);
    fetch(this.urlValue);
  }

  onChange() {
    const element = this.checkboxTarget;
    const value = element.checked;
    const url = this.urlValue;
    console.log(`changed to ${value} => ${url}`);
    put(url).then((response) => {
      console.log(response);
      const label = this.labelTarget;
      console.log(label);
      if (label) {
        label.innerHTML = value ? "visible" : "hidden";
      }
    });
  }

  // disconnect() {
  //   console.log("box_vixibility_controller disconnect");
  // }

  // // TODO: add flash message with put result
  // onEnd(event) {
  //   console.log("box_vixibility_controller onEnd");
  //   // const { newIndex, item } = event;
  //   // const url = item.dataset["sortableUrl"]
  //   // put(url, {
  //   //   body: JSON.stringify({ position: newIndex + 1 })
  //   // });
  // }
}