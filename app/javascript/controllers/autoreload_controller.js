// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: Number };

  connect() {
    console.log("autoreload_controller connected");
    console.log(this.element);
    // first reload is fired at randomized time (v% of/around intervalValue)
    const v = 20
    const i = this.intervalValue + Math.floor((Math.random() - 0.5) * this.intervalValue * v / 100);
    this.launch_reload(i);
  }

  launch_reload(i) {
    var o = this;
    setTimeout(
      function() {
        o.element.reload();
        o.launch_reload(o.intervalValue);
      },
      i
    )
  }
}
