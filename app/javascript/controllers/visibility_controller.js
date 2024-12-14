// app/javascript/controllers/box_visibility_controller.js
import { Controller } from "@hotwired/stimulus"
import { put } from "@rails/request.js";

export default class extends Controller {
  static values = { url: String };
  static targets = [ "checkbox", "label" ];

  connect() {
    console.log("vixibility_controller connect");
    console.log(this.element);
    fetch(this.urlValue);
  }

  onChange() {
    console.log(this.element);
    const value = this.element.querySelector("input[type='radio']:checked").value;
    const url = this.element.action;
    const body = {'award': {'audience': value}};
    put(url, {body: body}).then((response) => {
      console.log(response);
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