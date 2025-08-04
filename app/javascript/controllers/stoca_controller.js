import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // https://turbo.hotwired.dev/reference/events
    this.errorHandler = this.handleTurboFetchRequestError.bind(this)
    this.element.addEventListener("turbo:frame-missing", this.errorHandler)
    this.element.addEventListener("turbo:fetch-request-error", this.errorHandler)
  }

  disconnect() {
    this.element.removeEventListener("turbo:fetch-request-error", this.errorHandler)
    this.element.removeEventListener("turbo:frame-missing", this.errorHandler)
  }

  handleTurboFetchRequestError(event) {
    // const err = `
    //   Something went wrong on the server side. Please try again.
    //   If the problem persists, please contact support at 1234@epfl.ch.
    //   Une erreur s'est produite côté serveur. Veuillez réessayer.
    //   Si le problème persiste, veuillez contacter le service d'assistance
    //   à l'adresse 1234@epfl.ch.
    // `;

    // This is not very usefull because we get stuck in an incomplete/unfunctional page
    // if (this.element instanceof Turbo.FrameElement) {
    //   this.element.innerHTML = '<p>' + err + '</p>';
    // }
    // // dismiss all possibly dangling dismissable items
    // ["editor", "editor-overlay"].forEach((k) => {
    //   const e = document.getElementById(k);
    //   if (e) e.innerHTML = "";
    // })

    // // better to display an alert and full reload the page
    // alert(err);
    // location.reload();

    // or just redirect to the standard 500 error page
    window.location.replace("/500");
  }
}
