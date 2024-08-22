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

  // TODO: add flash message with put result
  onEnd(event) {
    const { newIndex, item } = event;
    const url = item.dataset["sortableUrl"]
    put(url, {
      body: JSON.stringify({ position: newIndex + 1 })
    });
  }
}