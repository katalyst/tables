import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class TurboCollectionController extends Controller {
  static values = {
    query: String,
    sort: String,
  };

  queryValueChanged(query) {
    Turbo.navigator.history.replace(this.#url(query));
  }

  sortValueChanged(sort) {
    document.querySelectorAll(this.#sortSelector).forEach((input) => {
      if (input) input.value = sort;
    });
  }

  get #sortSelector() {
    return "input[name='sort']";
  }

  #url(query) {
    const frame = this.element.closest("turbo-frame");
    let url;

    if (frame) {
      url = new URL(frame.baseURI);
    } else {
      url = new URL(window.location.href);
    }

    url.search = query;

    return url;
  }
}
