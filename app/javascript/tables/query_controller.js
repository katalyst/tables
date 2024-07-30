import { Controller } from "@hotwired/stimulus";

export default class QueryController extends Controller {
  static targets = ["modal"];

  disconnect() {
    delete this.pending;

    document.removeEventListener("selectionchange", this.selection);
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

    document.removeEventListener("selectionchange", this.selection);
  }

  openModal() {
    this.modalTarget.dataset.open = true;

    document.addEventListener("selectionchange", this.selection);
  }

  /**
   * If the user presses escape once, clear the input.
   * If the user presses escape again, get them out of here.
   */
  clear() {
    if (this.query.value === "") {
      this.closeModal();
    } else {
      this.query.value = "";
      this.query.dispatchEvent(new Event("input"));
      this.query.dispatchEvent(new Event("change"));
      this.update();
    }
  }

  submit() {
    const hasFocus = this.isFocused;
    const position = hasFocus && this.query.selectionStart;

    if (this.pending) {
      clearTimeout(this.pending);
      delete this.pending;
    }

    // prevent an unnecessary `?q=` parameter from appearing in the URL
    if (this.query.value === "") {
      this.query.disabled = true;

      // restore input and focus after form submission
      setTimeout(() => {
        this.query.disabled = false;
        if (hasFocus) this.query.focus();
      }, 0);
    }

    // add/remove current cursor position
    if (hasFocus) {
      this.position.value = position;
      this.position.disabled = false;
    } else {
      this.position.value = "";
      this.position.disabled = true;
    }
  }

  update = () => {
    if (this.pending) clearTimeout(this.pending);
    this.pending = setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  };

  selection = () => {
    if (this.isFocused && this.query.value.length > 0) this.update();
  };

  beforeMorphAttribute(e) {
    switch (e.detail.attributeName) {
      case "data-open":
        e.preventDefault();
        break;
    }
  }

  selectFirstSuggestion(e) {
    e.preventDefault();

    // Click the first item to ensure correct stimulus params are sent
    this.modalTarget.querySelector("#suggestions li:first-of-type").click();
  }

  selectSuggestion(e) {
    let value = e.params.value;
    if (/\s/.exec(value)) {
      value = `"${value}"`;
    }

    // NOTE - we would like to use this.position but can't due to it being blur
    this.query.dispatchEvent(
      new CustomEvent("replaceToken", {
        detail: { token: `${value} `, position: this.query.selectionStart },
      }),
    );
  }

  get query() {
    return this.element.querySelector("[role=searchbox]");
  }

  get position() {
    return this.element.querySelector("input[name=p]");
  }

  get isFocused() {
    return this.query === document.activeElement;
  }
}
