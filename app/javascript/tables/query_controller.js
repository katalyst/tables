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
    this.query.setAttribute("aria-expanded", false);

    if (document.activeElement === this.query) document.activeElement.blur();

    document.removeEventListener("selectionchange", this.selection);
  }

  openModal() {
    this.modalTarget.dataset.open = true;
    this.query.setAttribute("aria-expanded", true);

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

    // add/remove current cursor position
    if (hasFocus && this.query.value !== "") {
      this.position.value = position;
      this.position.disabled = false;
    } else {
      this.position.value = "";
      this.position.disabled = true;
    }

    // prevent an unnecessary `?q=&p=0` parameter from appearing in the URL
    if (this.query.value === "") {
      this.query.disabled = true;

      // restore input and focus after form submission
      setTimeout(() => {
        this.query.disabled = false;
        this.position.disabled = false;
        if (hasFocus) this.query.focus();
      }, 0);
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

  moveToPreviousSuggestion() {
    const prev = this.previousSuggestion || this.lastSuggestion;

    if (prev) this.makeSuggestionActive(prev);
  }

  moveToNextSuggestion() {
    const next = this.nextSuggestion || this.firstSuggestion;

    if (next) this.makeSuggestionActive(next);
  }

  selectFirstSuggestion(e) {
    // This is caused by pressing the tab key. We don't want to move focus.
    // Ideally we don't want to always prevent the user from tabbing. We will address this later
    e.preventDefault();

    this.firstSuggestion?.dispatchEvent(new CustomEvent("query:select"));
  }

  selectActiveSuggestion() {
    if (!this.activeSuggestion) {
      this.closeModal();
      return;
    }

    this.activeSuggestion.dispatchEvent(new CustomEvent("query:select"));
  }

  selectSuggestion(e) {
    this.query.dispatchEvent(
      new CustomEvent("replaceToken", {
        detail: { token: e.params.value, position: this.query.selectionStart },
      }),
    );

    this.clearActiveSuggestion();
  }

  makeSuggestionActive(node) {
    if (this.activeSuggestion) {
      this.activeSuggestion.setAttribute("aria-selected", "false");
    }

    this.query.setAttribute("aria-activedescendant", node.id);
    node.setAttribute("aria-selected", "true");
  }

  clearActiveSuggestion() {
    if (this.activeSuggestion) {
      this.activeSuggestion.setAttribute("aria-selected", "false");
      this.query.removeAttribute("aria-activedescendant");
    }
  }

  get activeSuggestion() {
    return this.modalTarget.querySelector(
      `#${this.query.getAttribute("aria-activedescendant")}`,
    );
  }

  get previousSuggestion() {
    return this.activeSuggestion?.previousElementSibling;
  }

  get nextSuggestion() {
    return this.activeSuggestion?.nextElementSibling;
  }

  get firstSuggestion() {
    return this.modalTarget.querySelector("#suggestions li:first-of-type");
  }

  get lastSuggestion() {
    return this.modalTarget.querySelector("#suggestions li:last-of-type");
  }

  get query() {
    return this.element.querySelector("[role=combobox]");
  }

  get position() {
    return this.element.querySelector("input[name=p]");
  }

  get isFocused() {
    return this.query === document.activeElement;
  }
}
