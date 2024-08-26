import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlPrefix", "valueField", "tagSelect"];

  connect() {
    this.updateUrlPrefix();
  }

  updateUrlPrefix() {
    const selectedTagOption = this.tagSelectTarget.selectedOptions[0];
    const baseUrl = selectedTagOption.getAttribute('data-url-prefix');
    const id = this.valueFieldTarget.value.trim();

    if (baseUrl) {
      this.urlPrefixTarget.textContent = id ? `${baseUrl}${id}` : baseUrl;
      this.valueFieldTarget.placeholder = selectedTagOption.getAttribute('data-placeholder');
    }
  }

  sanitizeValue() {
    const inputValue = this.valueFieldTarget.value.trim();

    for (const option of this.tagSelectTarget.options) {
      const url = option.getAttribute('data-url-prefix');
      if (inputValue.startsWith(url)) {
        this.valueFieldTarget.value = inputValue.replace(url, '');

        this.urlPrefixTarget.textContent = `${url}${this.valueFieldTarget.value}`;

        this.tagSelectTarget.value = option.value;

        this.valueFieldTarget.placeholder = option.getAttribute('data-placeholder');
        break;
      }
    }
  }

  tagChanged(event) {
    this.updateUrlPrefix();
  }

  checkLink() {
    const baseUrl = this.urlPrefixTarget.textContent;
    if (baseUrl) {
      window.open(baseUrl, '_blank');
    }
  }
}
