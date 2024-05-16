import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("flash controller connect");
    setTimeout(() => {
      this.dismiss();
    }, 3000);
  }

  dismiss() {
    console.log("flash controller dismiss");
    this.element.remove();
  }
}
