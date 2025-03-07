import { Controller } from "@hotwired/stimulus";
 
// https://blog.appsignal.com/2024/02/21/hotwire-modals-in-ruby-on-rails-with-stimulus-and-turbo-frames.html
// Connects to data-controller="remote-modal"
export default class extends Controller {
  connect() {
    this.element.showModal();
  }
  close() {
    this.element.close();
  }
}