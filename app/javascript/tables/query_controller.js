import { Controller } from "@hotwired/stimulus";

export default class QueryController extends Controller {
  static targets = ["modal"];

  disconnect() {
    delete this.pending;
  }

  focus() {
    if (document.activeElement === this.query) return;

    this.query.addEventListener(
      "focusin",
      (e) => {
        e.target.setSelectionRange(-1, -1);
      },
      { once: true },
    );

    this.query.focus();
  }

  closeModal() {
    delete this.modalTarget.dataset.open;

    if (document.activeElement === this.query) document.activeElement.blur();
  }

  openModal() {
    this.modalTarget.dataset.open = true;
  }

  clear() {
    if (this.query.value === "") {
      // if the user presses escape once, browser clears  the input
      // if the user presses escape again, get them out of here
      this.closeModal();
    }
  }

  submit() {
    if (this.pending) {
      clearTimeout(this.pending);
      delete this.pending;
    }

    // prevent an unnecessary `?q=` parameter from appearing in the URL
    if (this.query.value === "") {
      const hasFocus = this.query === document.activeElement;
      this.query.disabled = true;

      // restore input and focus after form submission
      setTimeout(() => {
        this.query.disabled = false;
        if (hasFocus) this.query.focus();
      }, 0);
    }
  }

  update() {
    this.pending ||= setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  }

  beforeMorphAttribute(e) {
    switch (e.detail.attributeName) {
      case "data-open":
        e.preventDefault();
        break;
    }
  }

  get query() {
    return this.element.querySelector("input[type=search]");
  }
}
