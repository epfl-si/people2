import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["urlPreview", "valueField"];
  static values = { pattern: String };

  sanitize(value) {
    try {
      const url = new URL(value.trim());
      const params = url.searchParams;
    
      // Others social
      const keys = ["user", "authorId", "authorID"];
      for (const key of keys) {
        if (params.has(key)) return params.get(key);
      }
    
      // LinkedIn / GitHub etc. → last segment of path
      const parts = url.pathname.split("/").filter(Boolean);
      if (parts.length) return parts[parts.length - 1];
    
      return value.trim();
    } catch {
      return value.trim();
    }
  }


  url() {
    const raw = this.valueFieldTarget.value.trim();
    const clean = this.sanitize(raw);
    return clean ? this.patternValue.replace("XXX", clean) : null;
  }

  onValueChange() {
    const clean = this.sanitize(this.valueFieldTarget.value);
    this.valueFieldTarget.value = clean;

    const url = this.patternValue.replace("XXX", clean);
    this.urlPreviewTarget.textContent = url;
    this.urlPreviewTarget.href = url;
  }
}
