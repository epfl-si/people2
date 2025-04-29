// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs";
import { put } from "@rails/request.js";

export default class extends Controller {
  static values = { url: String };

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 350,
      ghostClass: "bg-gray-200",
      onEnd: this.onEnd.bind(this),
    });
  }

  disconnect() {
    this.sortable.destroy();
  }

  onEnd(event) {
    const { newIndex, item } = event;
    const url = item.dataset["sortableUrl"]
    put(url, {
      body: JSON.stringify({ position: newIndex + 1 })
    }).then((response) => {
      if(response.response.ok) {
        // this.element.classList.add("ciccio");
        item.classList.add("sortable-done");
      } else {
        // this.element.classList.add("pasticcio");
        item.classList.add("sortable-error");
      }
      setTimeout(() => {
        item.classList.remove("sortable-done", "sortable-error");
      }, "2000");
    });
  }
}