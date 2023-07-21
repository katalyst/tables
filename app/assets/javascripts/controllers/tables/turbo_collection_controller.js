import { Controller } from "@hotwired/stimulus";

export default class TurboCollectionController extends Controller {
  static values = {
    url: String,
    sort: String,
  }

  urlValueChanged(url) {
    window.history.replaceState({}, "", this.urlValue);
  }

  sortValueChanged(sort) {
    document.querySelectorAll(this.#sortSelector).forEach((input) => {
      if (input) input.value = sort;
    });
  }

  get #sortSelector() {
    return "input[name='sort']";
  }
}
