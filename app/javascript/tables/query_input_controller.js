import { Controller } from "@hotwired/stimulus";

export default class QueryInputController extends Controller {
  static targets = ["input", "highlight"];
  static values = {query: String}

  connect() {
    this.queryValue = this.inputTarget.value;
  }

  update() {
    this.queryValue = this.inputTarget.value;
  }

  queryValueChanged(query) {
    this.highlightTarget.innerHTML = "";

    let match;
    while ((match = query.match(/\w+/))) {
      if (match.index !== 0) {
        this._addText(query.substring(0, match.index));
      }

      this._addTagged(match[0])

      query = query.substring(match.index + match[0].length);
    }

    this._addText(query);
  }

  _addText(value) {
    this.highlightTarget.appendChild(document.createTextNode(value));
  }

  _addTagged(value) {
    const span = document.createElement("span")
    span.className = "filter-tag"
    span.innerText = value;
    this.highlightTarget.appendChild(span);
  }
}
