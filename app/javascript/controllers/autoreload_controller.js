// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: Number };

  connect() {
    console.log("autoreload_controller connected");
    console.log(this.element);
    this.launch_reload();
  }

  launch_reload() {
    var o = this;
    setTimeout(
      function() {
        o.element.reload();
        o.launch_reload();
      },
      o.intervalValue
    )
  }
}
