// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs";
import { put } from "@rails/request.js";

// example use:
//
//    <ul data-controller="sortable">
//      <li data-sortable-url="/entries/211/positions"><i data-sortable-handle>(H)</i> one</li>
//      <li data-sortable-url="/entries/222/positions"><i data-sortable-handle>(H)</i> two</li>
//      <li data-sortable-url="/entries/233/positions"><i data-sortable-handle>(H)</i> three</li>
//    </ul>

export default class extends Controller {
  static values = { url: String };

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 350,
      ghostClass: "bg-gray-200",
      onEnd: this.onEnd.bind(this),
      handle: "[data-sortable-handle]",
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
    });
  }
}