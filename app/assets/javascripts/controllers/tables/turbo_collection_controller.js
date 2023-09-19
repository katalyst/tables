import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo";

export default class TurboCollectionController extends Controller {
  static values = {
    url: String,
    sort: String,
  };

  urlValueChanged(url) {
    Turbo.navigator.history.replace(this.#url(url));
  }

  sortValueChanged(sort) {
    document.querySelectorAll(this.#sortSelector).forEach((input) => {
      if (input) input.value = sort;
    });
  }

  get #sortSelector() {
    return "input[name='sort']";
  }

  #url(relativeUrl) {
    const frame = this.element.closest("turbo-frame");

    if (frame) {
      return new URL(relativeUrl, frame.baseURI);
    } else {
      return new URL(relativeUrl, window.location.href);
    }
  }
}
