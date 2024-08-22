import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlPrefix", "valueField", "tagSelect"];

  connect() {
    this.updateUrlPrefix();
  }

  updateUrlPrefix() {
    const selectedTag = this.tagSelectTarget.value;
    const baseUrl = this.getBaseUrl(selectedTag);
    const id = this.valueFieldTarget.value.trim();

    if (baseUrl) {
      this.urlPrefixTarget.textContent = id ? `${baseUrl}${id}` : baseUrl;
      this.valueFieldTarget.placeholder = this.getPlaceholder(selectedTag);
    }
  }

  sanitizeValue() {
    const inputValue = this.valueFieldTarget.value.trim();

    // Vérifie si l'entrée correspond à un réseau social connu
    for (const [key, value] of Object.entries(window.RESEARCH_IDS)) {
      const url = value.url.replace('XXX', '');
      if (inputValue.startsWith(url)) {
        // Raccourcit l'URL pour ne montrer que l'ID
        this.valueFieldTarget.value = inputValue.replace(url, '');

        // Met à jour le label du préfixe d'URL pour afficher l'URL complète avec l'ID
        this.urlPrefixTarget.textContent = `${url}${this.valueFieldTarget.value}`;

        // Change le tag sélectionné dans le menu déroulant
        this.tagSelectTarget.value = key;

        // Met à jour le placeholder avec l'exemple d'ID
        this.valueFieldTarget.placeholder = this.getPlaceholder(key);
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

  getBaseUrl(tag) {
    return window.RESEARCH_IDS[tag]?.url.replace('XXX', '') || '';
  }

  getPlaceholder(tag) {
    const placeholders = {
      'orcid': '0000-0002-1825-0097',
      'wos': 'AAX-5119-2020',
      'scopus': '57192201516',
      'googlescholar': 'abcdEFGhiJKLMno',
      'linkedin': 'john-doe-12345',
      'github': 'username',
      'stack_overflow': '12345678',
      'mastodon': 'username',
      'facebook': 'john.doe',
      'twitter': 'username',
      'instagram': '@username'
    };
    return placeholders[tag] || 'Enter ID or Username';
  }
}
