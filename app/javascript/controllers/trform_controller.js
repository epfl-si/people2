// app/javascript/controllers/switch_form_controller.js
// TPDO: could probably replace evertything with something more general as in
//       https://www.stimulus-components.com/docs/stimulus-remote-rails
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // static values = { model: String, field: String };
  static targets = ["form", "data"];

  connect() {
    console.log("trform controller connected");
  }

  show_form(event) {
    console.log("showing form");
    const data_td = event.target;
    const data_tr = data_td.closest("tr");
    const form_tr = data_tr.nextElementSibling;
    data_tr.classList.toggle("tr-hidden");
    form_tr.classList.toggle("tr-hidden");
  }

  // async save(event) {
  //   if (event.key === "Enter") {
  //     event.preventDefault();
  //     const resourceUrl = event.params.url;
  //     const fieldId = event.params.fieldId;
  //     const attribute = event.params.attribute;
  //     const body = {};

  //     body[attribute] = event.currentTarget.value;
  //     const response = await patch(resourceUrl, {
  //       body: body,
  //       responseKind: "turbo-stream",
  //     });
  //     if (response.ok) {
  //       this.editNextAttribute(fieldId);
  //     }
  //   }
  // }

  // cancel(event) {
  //   if (event.key === "Escape" || event.key === "Esc") {
  //     event.preventDefault();
  //     const resourceUrl = event.params.url;
  //     const attribute = event.params.attribute;
  //     const resourceName = event.params.resourceName;

  //     get(`${resourceUrl}?${resourceName}[${attribute}]=`, {
  //       responseKind: "turbo-stream",
  //     });
  //   }
  // }
}
